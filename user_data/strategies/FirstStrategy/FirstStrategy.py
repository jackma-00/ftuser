from freqtrade.strategy import IStrategy
from pandas import DataFrame
import talib.abstract as ta

class FirstStrategy(IStrategy):
    """
    FirstStrategy - RSI + SMA Strategy
    Conservative approach with RSI and Simple Moving Averages
    """

    timeframe = '5m'

    # set the initial stoploss to -10%
    stoploss = -0.10

    # exit profitable positions at any time when the profit is greater than 2%
    minimal_roi = {
        "60": 0.01,  # After 60 minutes, minimum 1%
        "30": 0.02,  # After 30 minutes, minimum 2%
        "0": 0.04    # Immediately, minimum 4%
    }

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # RSI
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=14)
        
        # Simple Moving Averages
        dataframe['sma_fast'] = ta.SMA(dataframe, timeperiod=9)
        dataframe['sma_slow'] = ta.SMA(dataframe, timeperiod=21)
        
        # Volume SMA for volume confirmation
        dataframe['volume_sma'] = ta.SMA(dataframe['volume'], timeperiod=20)

        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Entry: RSI oversold + fast SMA crosses above slow SMA + volume confirmation
        dataframe.loc[
            (
                (dataframe['rsi'] < 30) &  # RSI oversold
                (dataframe['sma_fast'] > dataframe['sma_slow']) &  # Fast MA above slow MA
                (dataframe['volume'] > dataframe['volume_sma']) &  # Volume above average
                (dataframe['close'] > dataframe['sma_fast'])  # Price above fast MA
            ),
            'enter_long'] = 1

        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Exit: RSI overbought OR fast SMA crosses below slow SMA
        dataframe.loc[
            (
                (dataframe['rsi'] > 70) |  # RSI overbought
                (dataframe['sma_fast'] < dataframe['sma_slow'])  # Fast MA below slow MA
            ),
            'exit_long'] = 1

        return dataframe 