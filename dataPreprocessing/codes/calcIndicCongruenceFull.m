%% help
% calculates indicator congruence for all cryptos which were traded based
% on pure technical analysis for whole available period
% input: none
% syntax: calcIndicCongruenceFull(), e.g. calcIndicCongruenceFull()
% output: absolute and relative indicator congruence for all cryptos

%% calculate indicator congruence for all cryptos
function [] =  calcIndicCongruenceFull()
    cryptos = ["btc", "eth", "ltc", "xmr", "xrp"];
    strat1_base_name = strcat("_trading_strat1_full.csv");
    strat2_base_name = strcat("_trading_strat2_full.csv");
    indic_cong_strat1 = cell(1, numel(cryptos));
    indic_cong_strat2 = cell(1, numel(cryptos));
    
    for i = 1:numel(cryptos)
        strat1_name = strcat(cryptos(i), strat1_base_name);
        strat2_name = strcat(cryptos(i), strat2_base_name);
        indic_cong_strat1{1, i} = rows2vars(calcIndicCongruence(strat1_name));
        indic_cong_strat2{1, i} = rows2vars(calcIndicCongruence(strat2_name));
    end
    variables = {'BTC', 'ETH', 'LTC',...
        'XMR', 'XRP'};
    rows = {'Indic. Cong. Table'};
    
    indic_cong_strat1 = cell2table(indic_cong_strat1);
    indic_cong_strat2 = cell2table(indic_cong_strat2);
    
    indic_cong_strat1.Properties.VariableNames = variables;
    indic_cong_strat2.Properties.VariableNames = variables;
    indic_cong_strat1.Properties.RowNames = rows;
    indic_cong_strat2.Properties.RowNames = rows;
    
    writetable(indic_cong_strat1, 'indicator_congruence_strat1_full.csv', 'WriteRowNames',true);
    writetable(indic_cong_strat2, 'indicator_congruence_strat2_full.csv', 'WriteRowNames',true);
end