%% help
% reads trinary vectors of decision for technical indicators and transforms
% input data for neural network to consist only of table where columns are
% vectors of decisions for these indicators
% input: data file to be changed
% syntax: addDataTrinary(data_file)
% e.g.: addDataTrinary('btc_data.csv')
% output: reduced data table

%% add trinary dec. vector to data input for neural network
function [] = addDataTrinary(data_file)
    [data, acc_dist, adx, aroon, bollinger, cci, gap, ichimoku, macd, ...
        on_bal_vol, rsi, stoch_osc] = readData(data_file);
    
    data = addvars(data, acc_dist, adx, aroon, bollinger, cci, gap, ichimoku, ....
        macd, on_bal_vol, rsi, stoch_osc);
    
    writeData(data, data_file);
end

%% read, write data
function [data, acc_dist, adx, aroon, bollinger, cci, gap, ichimoku, macd, ...
        on_bal_vol, rsi, stoch_osc] = readData(data_file)
    crypto_name = strsplit(data_file, '_');
    crypto_name = char(crypto_name(1,1));
    data = readtable(data_file);
    data = removevars(data, {%'Date', 'Open', 'High', 'Low', 'Close', 'Volume', 'MarketCap', ...
        'lead_span_a', 'lead_span_b', 'lagg_span', ...
        'adx', 'pos_dir_ind', 'neg_dir_ind', ...
        'fast_perc_k', 'fast_perc_d', ...
        'bol_low', 'bol_mid', 'bol_up', ...
        'macd_line', 'signal_line', ...
        'cci', 'rsi', 'interday_gap', 'daily_volume_change', 'acc_dist_line', 'aroon_osc', 'on_balance_volume'});

    acc_dist = table2array(readtable(strcat(crypto_name, '_dec_tech_an_accDist_trinary.csv')));
    adx = table2array(readtable(strcat(crypto_name, '_dec_tech_an_adx_trinary.csv')));
    aroon = table2array(readtable(strcat(crypto_name, '_dec_tech_an_aroon_trinary.csv')));
    bollinger = table2array(readtable(strcat(crypto_name, '_dec_tech_an_bollinger_trinary.csv')));
    cci = table2array(readtable(strcat(crypto_name, '_dec_tech_an_cci_trinary.csv')));
    gap = table2array(readtable(strcat(crypto_name, '_dec_tech_an_gap_trinary.csv')));
    ichimoku = table2array(readtable(strcat(crypto_name, '_dec_tech_an_ichimoku_trinary.csv')));
    macd = table2array(readtable(strcat(crypto_name, '_dec_tech_an_macd_trinary.csv')));
    on_bal_vol = table2array(readtable(strcat(crypto_name, '_dec_tech_an_onBalVol_trinary.csv')));
    rsi = table2array(readtable(strcat(crypto_name, '_dec_tech_an_rsi_trinary.csv')));
    stoch_osc = table2array(readtable(strcat(crypto_name, '_dec_tech_an_stochOsc_trinary.csv')));
end

function [] = writeData(data, data_file)
    filename = erase(data_file, '.csv');
    filename = strcat(filename, '_red.csv');
    writetable(data, filename);
end