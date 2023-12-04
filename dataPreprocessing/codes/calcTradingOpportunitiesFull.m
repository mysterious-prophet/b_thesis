%% help
% calculates trading opportunities of classical technical analysis and
% technical analysis with added empirical rules 1 and 2
% input: none
% syntax: calcTradingOpportunitiesFull(), e.g.
% calcTradingOpportunitiesFull()
% output: trading opportunities of classical technical analysis and
% technical analysis with added empirical rules for all cryptocurrencies
% used in the project

%% calculate trading opportunities for all cryptos
function [] = calcTradingOpportunitiesFull()
    cryptos = ["btc", "eth", "ltc", "xmr", "xrp"];
    data_base_filename = "_data";
    decision_base_filename = "_dec_tech_an_";
    indicators = ["accDist", "adx", "aroon", "bollinger", "cci", "gap", ...
        "ichimoku", "macd", "onBalVol", "rsi", "stochOsc", "full"];
    extension = ".csv";
    trading_opps_classic_all = cell(numel(indicators), numel(cryptos));
    trading_opps_empir_all = cell(numel(indicators), numel(cryptos));
    for i = 1:numel(cryptos)
        data_filename = convertStringsToChars(strcat(cryptos(i), data_base_filename, extension));
        for j = 1:numel(indicators)
           decision_filename = convertStringsToChars(strcat(cryptos(i), decision_base_filename, ...
               indicators(j), extension));
           [trading_opps_classic_all{j, i}, trading_opps_empir_all{j, i}] = calcTradingOpportunities(data_filename, decision_filename);
        end
    end
    variables = {'BTC', 'ETH', 'LTC',...
        'XMR', 'XRP'};
    rows = ["A/D", "ADX", "Aroon", "Boll. Bands", "CCI", "Gap An.", ...
        "Ich. Cloud", "MACD", "OBV", "RSI", "Stoch. Osc.", "Full An."];
    
    trading_opps_classic_all = cell2table(trading_opps_classic_all);
    trading_opps_empir_all = cell2table(trading_opps_empir_all);
    trading_opps_classic_all.Properties.VariableNames = variables;
    trading_opps_empir_all.Properties.VariableNames = variables;
    trading_opps_classic_all.Properties.RowNames = rows;
    trading_opps_empir_all.Properties.RowNames = rows;
    
    writetable(trading_opps_classic_all, 'trading_opportunities_classic_full.csv','WriteRowNames',true);
    writetable(trading_opps_empir_all, 'trading_opportunities_empir_full.csv', 'WriteRowNames',true);
end