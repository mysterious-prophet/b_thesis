%% help
% calculates trading opportunities for one crypto as seen in in tables 5.7, 5.8 in
% bachelor's project
% input: file with crypto data, file with business decisions
% syntax: calcTradingOpportunities(<data_file.csv>, <decision_file.csv>)
% e.g. calcTradingOpportunities('btc_data.csv', 'btc_dec_tech_an_full.csv')
% output: trading opportunities in sense buy:sell for classical technical
% analysis and technical analysis with empirical rules 1 and 2 added

%% calculate trading opportunities
function [trading_opps_classic, trading_opps_empir] = calcTradingOpportunities(data_file, decision_file)
    [data, decision, crypto_name, indicator] = readData(data_file, decision_file);
    [buy_opps_classic, sell_opps_classic] = execTradingOppsClassic(decision);
    buy_opps_classic = num2str(buy_opps_classic);
    sell_opps_classic = num2str(sell_opps_classic);
    %trading_opps_classic = table(buy_opps_classic, sell_opps_classic);
    trading_opps_classic = strcat(buy_opps_classic, ':', sell_opps_classic); 
    target = decision;
    target = empirRule1(target, decision);
    target = empirRule2(target, data);
    [buy_opps_empir, sell_opps_empir] = execTradingOppsEmpir(target);
    %trading_opps_empir = [buy_opps_empir; sell_opps_empir];
    buy_opps_empir = num2str(buy_opps_empir);
    sell_opps_empir= num2str(sell_opps_empir);
    trading_opps_empir = strcat(buy_opps_empir, ':', sell_opps_empir); 
    %trading_opps_empir = table(buy_opps_empir, sell_opps_empir);
    %writeData(trading_opps_classic, trading_opps_empir, crypto_name, indicator);
end

%% read and write data
function [data, decision, crypto_name, indicator] = readData(data_file, decision_file)
    data = readtable(data_file);
    decision = readtable(decision_file);
    crypto_name = data_file(1:3);
    indicator = strsplit(decision_file, '_');
    indicator = indicator{5}(1:end-4);
end

% write function is not used as this function became en exec of larger
% cycle
% function [] = writeData(trading_opps_classic, trading_opps_empir, crypto_name, indicator)
%     filename_classic = strcat(crypto_name, '_tradingOppsClassic_', indicator, '.csv');
%     filename_empir = strcat(crypto_name, '_tradingOppsEmpir_', indicator, '.csv');
%     writetable(trading_opps_classic, filename_classic);
%     writetable(trading_opps_empir, filename_empir);
% end

%% calculate trading opportunities for classic technical analysis
function [buyOpps, sellOpps] = execTradingOppsClassic(decision)
    buyOpps = 0; sellOpps = 0;
    for i = 1:height(decision)
        if(decision.Buy(i) > decision.Sell(i) + decision.Hold(i))
            buyOpps = buyOpps + 1;
        elseif(decision.Sell(i) > decision.Buy(i) + decision.Hold(i))
            sellOpps = sellOpps + 1;
        end
    end
end

%% empirical rules 1 and 2
% empirical rule 1
function [target] = empirRule1(target, decision)
    for i = 1:height(decision)
        if(decision.Buy(i) > decision.Sell(i))
            target.Buy(i) = 1;
        elseif(decision.Sell(i) > decision.Buy(i))
            target.Sell(i) = 1;
        else
            target.Hold(i) = 1;
        end
    end
end

% buy
function [target] = empirRule2(target, data)
    close = data.Close;
    open = data.Open;
    high = data.High;
    low = data.Low;
    avg_true_range = stop_loss(high, low, close);
    lost_oppors = 0;
    lost_oppors_indcs = zeros(size(close,1),1);
    k = 1;
    stop_loss_coef = 3;
    stop_loss_price = 0;
    gap_coef = 0.08;
    for i = 15:size(close)
        if(target.Buy(i) == 1)
            stop_loss_price = close(i-1) - stop_loss_coef * avg_true_range(i-1);
        end
        
        if((open(i) > (1 + gap_coef)*close(i-1) && target.Buy(i) == 0) || ...
                (close(i) < stop_loss_price && target.Sell(i) == 0))
            lost_oppors = lost_oppors + 1;
            lost_oppors_indcs(k) = i;
            k = k + 1;
        end
    end
    
    lost_oppors_indcs = lost_oppors_indcs(1:lost_oppors);
    for i = 1:size(lost_oppors_indcs)
        if(close(lost_oppors_indcs(i)) < close(lost_oppors_indcs(i) - 1))
            target.Sell(lost_oppors_indcs(i)) = 1;
            target.Buy(lost_oppors_indcs(i)) = 0;
            target.Hold(lost_oppors_indcs(i)) = 0;
        elseif(close(lost_oppors_indcs(i)) > close(lost_oppors_indcs(i) - 1))
            target.Buy(lost_oppors_indcs(i)) = 1;
            target.Sell(lost_oppors_indcs(i)) = 0;
            target.Hold(lost_oppors_indcs(i)) = 0;
        end
    end
end
% calculate stop_loss for rule_2
function [average_true_range] =  stop_loss(high, low, close)
    true_range = zeros(size(close));
    for i=2:size(close)
       temp_1 =  high(i) - low(i);
       temp_2 = high(i) - close(i-1);
       temp_3 = low(i) - close(i-1);
       temp_4 = [temp_1 temp_2 temp_3];
       true_range(i) = max(temp_4); 
    end
    n = 14;
    average_true_range = zeros(size(close));
    average_true_range_temp = 0;
    for i=n+1:size(close)
       for j=i-n:i
            average_true_range_temp = average_true_range_temp + true_range(j);
       end
       average_true_range_temp = average_true_range_temp / n;
       average_true_range(i) = average_true_range_temp;
       average_true_range_temp = 0;
    end
end

%% calculate trading opportunities including empirical rules
function [buyOpps, sellOpps] = execTradingOppsEmpir(decision)
    buyOpps = 0; sellOpps = 0;
    for i = 1:height(decision)
        if(decision.Buy(i) > decision.Sell(i))
            buyOpps = buyOpps + 1;
        elseif(decision.Sell(i) > decision.Buy(i))
            sellOpps = sellOpps + 1;
        end
    end
end