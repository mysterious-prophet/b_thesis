import pandas as pd
import requests
import lxml
import time
import datetime
import array as arr


#read data from html table to btc_data dataframe
btc_data = pd.read_html("https://coinmarketcap.com/currencies/bitcoin/historical-data/?start=20130429&end=20201209",
                        header=0)

#data cleaning
btc_data = btc_data.assign(Date=pd.to_datetime(btc_data['Date']))
btc_data.loc[btc_data['Volume'] == "-", 'Volume'] = 0
btc_data['Volume'] = btc_data['Volume'].astype('int64')
btc_data.rename(columns={'Open*': 'Open', 'Close**': 'Close'}, inplace=True)
#output data to csv file for matlab read
btc_file = 'btc_data.csv'
btc_data.to_csv(btc_file, encoding='utf-8', index=False)

eth_data = pd.read_html("https://coinmarketcap.com/currencies/ethereum/historical-data/?start=20130429&end=20200331",
                        header=0)[2]
eth_data = eth_data.assign(Date=pd.to_datetime(eth_data['Date']))
eth_data.loc[eth_data['Volume'] == "-", 'Volume'] = 0
eth_data['Volume'] = eth_data['Volume'].astype('int64')
eth_data.rename(columns={'Open*': 'Open', 'Close**': 'Close'}, inplace=True)
eth_file = 'eth_data.csv'
eth_data.to_csv(eth_file, encoding='utf-8', index=False)

xrp_data = pd.read_html("https://coinmarketcap.com/currencies/xrp/historical-data/?start=20130429&end=20200331",
                        header=0)[2]
xrp_data = xrp_data.assign(Date=pd.to_datetime(xrp_data['Date']))
xrp_data.loc[xrp_data['Volume'] == "-", 'Volume'] = 0
xrp_data['Volume'] = xrp_data['Volume'].astype('int64')
xrp_data.rename(columns={'Open*': 'Open', 'Close**': 'Close'}, inplace=True)
xrp_file = 'xrp_data.csv'
xrp_data.to_csv(xrp_file, encoding='utf-8', index=False)

ltc_data = pd.read_html("https://coinmarketcap.com/currencies/litecoin/historical-data/?start=20130429&end=20200331",
                        header=0)[2]
ltc_data = ltc_data.assign(Date=pd.to_datetime(ltc_data['Date']))
ltc_data.loc[ltc_data['Volume'] == "-", 'Volume'] = 0
ltc_data['Volume'] = ltc_data['Volume'].astype('int64')
ltc_data.rename(columns={'Open*': 'Open', 'Close**': 'Close'}, inplace=True)
ltc_file = 'ltc_data.csv'
ltc_data.to_csv(ltc_file, encoding='utf-8', index=False)

xmr_data = pd.read_html("https://coinmarketcap.com/currencies/monero/historical-data/?start=20140521&end=20200331",
                        header=0)[2]
xmr_data = xmr_data.assign(Date=pd.to_datetime(xmr_data['Date']))
xmr_data.loc[xmr_data['Volume'] == "-", 'Volume'] = 0
xmr_data['Volume'] = xmr_data['Volume'].astype('int64')
xmr_data.rename(columns={'Open*': 'Open', 'Close**': 'Close'}, inplace=True)
xmr_file = 'xmr_data.csv'
xmr_data.to_csv(xmr_file, encoding='utf-8', index=False)
