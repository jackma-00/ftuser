from freqtrade.strategy import IStrategy
from pandas import DataFrame
import talib.abstract as ta

class ThirdStrategy(IStrategy):
    """
    ThirdStrategy - Bollinger Bands + Stochastic Strategy
    Mean reversion approach with Bollinger Bands and Stochastic oscillator
    """

    timeframe = '1m'

    # set the initial stoploss to -12% (more aggressive)
    stoploss = -0.12

    # exit profitable positions quickly for scalping
    minimal_roi = {
        "10": 0.01,  # After 10 minutes, minimum 1%
        "5": 0.02,   # After 5 minutes, minimum 2%
        "0": 0.03    # Immediately, minimum 3%
    }

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Bollinger Bands
        bollinger = ta.BBANDS(dataframe, timeperiod=20, nbdevup=2.0, nbdevdn=2.0, matype=0)
        dataframe['bb_lowerband'] = bollinger['lowerband']
        dataframe['bb_middleband'] = bollinger['middleband']
        dataframe['bb_upperband'] = bollinger['upperband']
        
        # Stochastic oscillator
        stoch = ta.STOCH(dataframe)
        dataframe['slowk'] = stoch['slowk']
        dataframe['slowd'] = stoch['slowd']
        
        # Williams %R
        dataframe['willr'] = ta.WILLR(dataframe, timeperiod=14)
        
        # Price position within Bollinger Bands
        dataframe['bb_percent'] = (dataframe['close'] - dataframe['bb_lowerband']) / (dataframe['bb_upperband'] - dataframe['bb_lowerband'])

        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Entry: Price near lower Bollinger Band + Stochastic oversold + Williams %R oversold
        dataframe.loc[
            (
                (dataframe['close'] < dataframe['bb_lowerband']) &  # Price below lower BB
                (dataframe['bb_percent'] < 0.2) &  # Close to lower band
                (dataframe['slowk'] < 20) &  # Stochastic oversold
                (dataframe['slowd'] < 20) &  # Stochastic signal oversold
                (dataframe['willr'] < -80) &  # Williams %R oversold
                (dataframe['volume'] > 0)  # Volume confirmation
            ),
            'enter_long'] = 1

        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Exit: Price near upper Bollinger Band OR Stochastic overbought
        dataframe.loc[
            (
                (dataframe['close'] > dataframe['bb_upperband']) |  # Price above upper BB
                (dataframe['bb_percent'] > 0.8) |  # Close to upper band
                (dataframe['slowk'] > 80) |  # Stochastic overbought
                (dataframe['willr'] > -20)  # Williams %R overbought
            ),
            'exit_long'] = 1

        return dataframe 