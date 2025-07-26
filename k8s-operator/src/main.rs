use kube::{
    api::{Api, Patch, PatchParams, ResourceExt},
    client::Client,
    runtime::{controller::Action, watcher, Controller},
    CustomResource,
};
use k8s_openapi::api::{
    apps::v1::{Deployment, DeploymentSpec},
    core::v1::{Container, ContainerPort, PodSpec, PodTemplateSpec, Service, Volume, VolumeMount},
};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
use std::{collections::BTreeMap, sync::Arc, time::Duration as StdDuration};
use tokio::time::Duration;
use tracing::{info, warn, error};
use futures::stream::StreamExt;

#[derive(Debug)]
struct OperatorError(String);

impl std::fmt::Display for OperatorError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl std::error::Error for OperatorError {}

impl From<kube::Error> for OperatorError {
    fn from(err: kube::Error) -> Self {
        OperatorError(err.to_string())
    }
}

impl From<serde_json::Error> for OperatorError {
    fn from(err: serde_json::Error) -> Self {
        OperatorError(err.to_string())
    }
}

type Result<T> = std::result::Result<T, OperatorError>;

#[derive(CustomResource, Debug, Serialize, Deserialize, Default, Clone, JsonSchema)]
#[kube(group = "trading.io", version = "v1", kind = "TradingStrategy")]
#[kube(namespaced)]
#[kube(status = "TradingStrategyStatus")]
pub struct TradingStrategySpec {
    pub name: String,
    pub strategy_class: String,
    pub image: Option<String>,
    pub port: Option<u16>,
    pub resources: Option<ResourceConfig>,
}

#[derive(Debug, Serialize, Deserialize, Clone, JsonSchema, Default)]
pub struct ResourceConfig {
    pub cpu: String,
    pub memory: String,
}

#[derive(Debug, Serialize, Deserialize, Clone, JsonSchema, Default)]
pub struct TradingStrategyStatus {
    pub phase: String,
    pub message: Option<String>,
    pub last_updated: Option<String>,
}

async fn reconcile(strategy: Arc<TradingStrategy>, ctx: Arc<OperatorContext>) -> Result<Action> {
    let client = &ctx.client;
    let name = strategy.name_any();
    let namespace = strategy.namespace().unwrap_or_else(|| "default".to_string());

    info!("Reconciling TradingStrategy: {} in namespace: {}", name, namespace);

    // Create or update deployment
    let deployment = build_deployment(&strategy)?;
    let deployments: Api<Deployment> = Api::namespaced(client.clone(), &namespace);
    
    deployments
        .patch(
            &name,
            &PatchParams::apply("trading-operator"),
            &Patch::Apply(&deployment),
        )
        .await?;

    // Create or update service
    let service = build_service(&strategy)?;
    let services: Api<Service> = Api::namespaced(client.clone(), &namespace);
    
    services
        .patch(
            &name,
            &PatchParams::apply("trading-operator"),
            &Patch::Apply(&service),
        )
        .await?;

    info!("Successfully reconciled TradingStrategy: {}", name);
    Ok(Action::requeue(Duration::from_secs(30)))
}

fn build_deployment(strategy: &TradingStrategy) -> Result<Deployment> {
    let name = &strategy.spec.name;
    let strategy_class = &strategy.spec.strategy_class;
    let image = strategy.spec.image.as_ref()
        .unwrap_or(&"freqtradeorg/freqtrade:stable".to_string())
        .clone();
    
    // Get the port from config (each strategy uses a different port)
    let container_port = strategy.spec.port.unwrap_or(8080);
    
    let mut labels = BTreeMap::new();
    labels.insert("app".to_string(), name.clone());
    labels.insert("managed-by".to_string(), "trading-operator".to_string());

    // Volume mount for user_data
    let volume_mounts = vec![VolumeMount {
        name: "user-data".to_string(),
        mount_path: "/freqtrade/user_data".to_string(),
        read_only: Some(false),
        ..Default::default()
    }];

    // Container uses exact commands from docker-compose-multi.yml
    let container = Container {
        name: "freqtrade".to_string(),
        image: Some(image),
        command: Some(vec![
            "freqtrade".to_string(),
            "trade".to_string(),
        ]),
        args: Some(vec![
            "--logfile".to_string(),
            format!("/freqtrade/user_data/logs/{}/freqtrade.log", strategy_class),
            "--db-url".to_string(),
            format!("sqlite:////freqtrade/user_data/logs/{}/trades.sqlite", strategy_class),
            "--config".to_string(),
            format!("/freqtrade/user_data/strategies/{}/config_dryrun.json", strategy_class),
            "--strategy".to_string(),
            strategy_class.clone(),
            "--strategy-path".to_string(),
            format!("/freqtrade/user_data/strategies/{}", strategy_class),
        ]),
        ports: Some(vec![ContainerPort {
            container_port: container_port as i32,
            ..Default::default()
        }]),
        volume_mounts: Some(volume_mounts),
        // Apply resource limits if specified
        resources: strategy.spec.resources.as_ref().map(|res| {
            k8s_openapi::api::core::v1::ResourceRequirements {
                requests: Some({
                    let mut requests = BTreeMap::new();
                    requests.insert("cpu".to_string(), k8s_openapi::apimachinery::pkg::api::resource::Quantity(res.cpu.clone()));
                    requests.insert("memory".to_string(), k8s_openapi::apimachinery::pkg::api::resource::Quantity(res.memory.clone()));
                    requests
                }),
                limits: Some({
                    let mut limits = BTreeMap::new();
                    limits.insert("cpu".to_string(), k8s_openapi::apimachinery::pkg::api::resource::Quantity(res.cpu.clone()));
                    limits.insert("memory".to_string(), k8s_openapi::apimachinery::pkg::api::resource::Quantity(res.memory.clone()));
                    limits
                }),
                ..Default::default()
            }
        }),
        ..Default::default()
    };

    // Volume definition for user_data (using HostPath for local development)
    let volumes = vec![Volume {
        name: "user-data".to_string(),
        host_path: Some(k8s_openapi::api::core::v1::HostPathVolumeSource {
            path: "/freqtrade/user_data".to_string(),
            type_: Some("Directory".to_string()),
        }),
        ..Default::default()
    }];

    let deployment = Deployment {
        metadata: k8s_openapi::apimachinery::pkg::apis::meta::v1::ObjectMeta {
            name: Some(name.clone()),
            labels: Some(labels.clone()),
            ..Default::default()
        },
        spec: Some(DeploymentSpec {
            replicas: Some(1),
            selector: k8s_openapi::apimachinery::pkg::apis::meta::v1::LabelSelector {
                match_labels: Some(labels.clone()),
                ..Default::default()
            },
            template: PodTemplateSpec {
                metadata: Some(k8s_openapi::apimachinery::pkg::apis::meta::v1::ObjectMeta {
                    labels: Some(labels),
                    ..Default::default()
                }),
                spec: Some(PodSpec {
                    containers: vec![container],
                    volumes: Some(volumes),
                    ..Default::default()
                }),
            },
            ..Default::default()
        }),
        ..Default::default()
    };

    Ok(deployment)
}

fn build_service(strategy: &TradingStrategy) -> Result<Service> {
    let name = &strategy.spec.name;
    let container_port = strategy.spec.port.unwrap_or(8080);
    
    let mut labels = BTreeMap::new();
    labels.insert("app".to_string(), name.clone());

    let service = Service {
        metadata: k8s_openapi::apimachinery::pkg::apis::meta::v1::ObjectMeta {
            name: Some(name.clone()),
            labels: Some(labels.clone()),
            ..Default::default()
        },
        spec: Some(k8s_openapi::api::core::v1::ServiceSpec {
            selector: Some(labels),
            ports: Some(vec![k8s_openapi::api::core::v1::ServicePort {
                port: container_port as i32,
                target_port: Some(k8s_openapi::apimachinery::pkg::util::intstr::IntOrString::Int(container_port as i32)),
                ..Default::default()
            }]),
            ..Default::default()
        }),
        ..Default::default()
    };

    Ok(service)
}

fn error_policy(_obj: Arc<TradingStrategy>, _error: &OperatorError, _ctx: Arc<OperatorContext>) -> Action {
    warn!("Reconcile error: {}", _error);
    Action::requeue(Duration::from_secs(60))
}

#[derive(Clone)]
struct OperatorContext {
    client: Client,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();
    
    info!("🚀 Starting Trading Strategy Operator");

    // Test Kubernetes connectivity
    let client = match Client::try_default().await {
        Ok(client) => {
            info!("✅ Successfully connected to Kubernetes API");
            client
        },
        Err(e) => {
            error!("❌ Failed to connect to Kubernetes API: {}", e);
            return Err(e.into());
        }
    };

    let strategies: Api<TradingStrategy> = Api::default_namespaced(client.clone());
    
    // Test if we can access the CRD
    match strategies.list(&Default::default()).await {
        Ok(list) => {
            info!("✅ Successfully accessed TradingStrategy CRD, found {} existing strategies", list.items.len());
        }
        Err(e) => {
            error!("❌ Failed to access TradingStrategy CRD: {}", e);
            return Err(e.into());
        }
    }

    let ctx = Arc::new(OperatorContext { client });

    info!("🎯 Starting controller loop...");
    
    // Run the controller with proper error handling
    loop {
        let controller_result = Controller::new(strategies.clone(), watcher::Config::default())
            .run(reconcile, error_policy, ctx.clone())
            .for_each(|res| async move {
                match res {
                    Ok(o) => info!("✅ Reconciled: {:?}", o),
                    Err(e) => error!("❌ Reconcile error: {}", e),
                }
            })
            .await;

        error!("🔄 Controller loop ended, restarting in 5 seconds...");
        tokio::time::sleep(Duration::from_secs(5)).await;
    }
} 