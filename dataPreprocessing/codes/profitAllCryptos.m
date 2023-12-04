%% help
% calculates profit for all cryptos for the whole available time period
% based on pure technical analysis
% input: initial funds size, maximum risk coefficient per one trade
% syntax: profitAllCryptos(initial_funds, max_risk_coefficient)
% e.g.: profitAllCryptos(10000, 0.02);
% output: profits for both OS1 and OS2 for all cryptos based on technical
% analysis

%% calculate profit for all cryptos
function [] = profitAllCryptos(initial_funds, max_risk_coeff)
    cryptos = ["btc", "eth", "ltc", "xmr", "xrp"];
    base_data_filename = '_data.csv';
    base_techAn_filename = '_dec_tech_an_full.csv';
    for i = 1:5
        data_filename = strcat(cryptos(i), base_data_filename);
        techAn_filename = strcat(cryptos(i), base_techAn_filename);
        execTrading(data_filename, techAn_filename, initial_funds, max_risk_coeff, 1);
        execTrading(data_filename, techAn_filename, initial_funds, max_risk_coeff, 2);
    end
end