from freqtrade.strategy import IStrategy
from pandas import DataFrame
import talib.abstract as ta

class SecondStrategy(IStrategy):
    """
    SecondStrategy - EMA Crossover + MACD Strategy
    Trend-following approach with EMA crossovers and MACD confirmation
    """

    timeframe = '15m'

    # set the initial stoploss to -8%
    stoploss = -0.08

    # exit profitable positions with different timeframes
    minimal_roi = {
        "120": 0.01,  # After 2 hours, minimum 1%
        "60": 0.02,   # After 1 hour, minimum 2%
        "20": 0.03,   # After 20 minutes, minimum 3%
        "0": 0.05     # Immediately, minimum 5%
    }

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Exponential Moving Averages
        dataframe['ema_fast'] = ta.EMA(dataframe, timeperiod=12)
        dataframe['ema_slow'] = ta.EMA(dataframe, timeperiod=26)
        
        # MACD
        macd = ta.MACD(dataframe)
        dataframe['macd'] = macd['macd']
        dataframe['macdsignal'] = macd['macdsignal']
        dataframe['macdhist'] = macd['macdhist']
        
        # ADX for trend strength
        dataframe['adx'] = ta.ADX(dataframe, timeperiod=14)

        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Entry: EMA fast crosses above slow + MACD bullish + strong trend
        dataframe.loc[
            (
                (dataframe['ema_fast'] > dataframe['ema_slow']) &  # Fast EMA above slow EMA
                (dataframe['macd'] > dataframe['macdsignal']) &  # MACD above signal
                (dataframe['macdhist'] > 0) &  # MACD histogram positive
                (dataframe['adx'] > 25) &  # Strong trend
                (dataframe['close'] > dataframe['ema_fast'])  # Price above fast EMA
            ),
            'enter_long'] = 1

        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Exit: EMA fast crosses below slow OR MACD bearish
        dataframe.loc[
            (
                (dataframe['ema_fast'] < dataframe['ema_slow']) |  # Fast EMA below slow EMA
                (dataframe['macd'] < dataframe['macdsignal']) |  # MACD below signal
                (dataframe['adx'] < 20)  # Weak trend
            ),
            'exit_long'] = 1

        return dataframe 