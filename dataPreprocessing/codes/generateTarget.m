%% help
% generates target for neural network classification based on technical
% analysis and empirical rules 0-4, plots signals on close prices
% input: technical analysis decision file, data file for calculating stop
% loss orders
% syntax: generateTarget(decision_file, data_file)
% e.g.: generateTarget('btc_dec_tech_an_full.csv', 'btc_data_red.csv')
% output: target table with columns buy/hold/sell, plot of signals 

%% generate target
function [target] = generateTarget(decision_file, data_file)
    [decision, target, data] = readData(decision_file, data_file);
    
%     decision = empirRule0();
%     decision = array2table(decision);
%     decision.Properties.VariableNames = {'Buy', 'Hold', 'Sell'};
    
    target = empirRule1(target, decision);
    target = empirRule2(target, data);
    
%     target = table2array(target);
%     for i = 1:size(target)
%         for j = 1:3
%             if(target(i, j) ~= 1)
%                target(i, j) = 0; 
%             end
%         end
%     end
%     target = array2table(target);
%     target.Properties.VariableNames = {'Buy', 'Hold', 'Sell'};
    %target = empirRule3(target);
    %target = empirRule4(target);
    
    plotSignals(target, data, data_file);
    writeData(target, data_file);
end

%% read and write data
function [decision, target, data] = readData(decision_file, data_file)
    decision = readtable(decision_file);
    target = zeros(height(decision),3);
    target = array2table(target);
    target.Properties.VariableNames = {'Buy', 'Hold', 'Sell'};
    data = readtable(data_file);
end

function [] = writeData(target, data_file)
    filename = data_file;
    filename = erase(filename, '_data.csv');
    filename = erase(filename, '_data_red.csv');
    filename = strcat(filename, '_target', '.csv');
    writetable(target, filename);
end

%% empirical rules

%% rule 0 - not used, described in chapter 5
% gives initial weights to technical vectors based on their congruence
% with overall decision of full technical analysis
% function [target] = empirRule0()
%     ind_cong = readtable('btc_ind_cong.csv');
%     ind_cong.Properties.RowNames = {'acc_dist_abs', 'acc_dist_rel',...
%         'adx_abs', 'adx_rel', 'aroon_abs', 'aroon_rel', 'bollinger_abs', ...
%         'bollinger_rel', 'cci_abs', 'cci_rel', 'gap_abs', 'gap_rel', ...
%         'ichimoku_abs', 'ichimoku_rel', 'macd_abs', 'macd_rel', ...
%         'on_bal_vol_abs', 'on_bal_vol_rel', 'rsi_abs', 'rsi_rel', ...
%         'stoch_osc_abs', 'stoch_osc_rel'};
%     acc_dist = table2array(ind_cong('acc_dist_rel', 2)).*table2array(readtable('btc_dec_tech_an_accDist.csv'));
%     adx = table2array(ind_cong('adx_rel', 2)).*table2array(readtable('btc_dec_tech_an_adx.csv'));
%     aroon = table2array(ind_cong('aroon_rel', 2)).*table2array(readtable('btc_dec_tech_an_aroon.csv'));
%     bollinger = table2array(ind_cong('bollinger_rel', 2)).*table2array(readtable('btc_dec_tech_an_bollinger.csv'));
%     cci = table2array(ind_cong('cci_rel', 2)).*table2array(readtable('btc_dec_tech_an_cci.csv'));
%     gap = table2array(ind_cong('gap_rel', 2)).*table2array(readtable('btc_dec_tech_an_gap.csv'));
%     ichimoku =  table2array(ind_cong('ichimoku_rel', 2)).*table2array(readtable('btc_dec_tech_an_ichimoku.csv'));
%     macd = table2array(ind_cong('macd_rel', 2)).*table2array(readtable('btc_dec_tech_an_macd.csv'));
%     on_bal_vol = table2array(ind_cong('on_bal_vol_rel', 2)).*table2array(readtable('btc_dec_tech_an_onBalVol.csv'));
%     rsi =  table2array(ind_cong('rsi_rel', 2)).*table2array(readtable('btc_dec_tech_an_rsi.csv'));
%     stoch_osc = table2array(ind_cong('stoch_osc_rel', 2)).*table2array(readtable('btc_dec_tech_an_stochOsc.csv'));
%     
% %     target = acc_dist + adx + aroon + bollinger + cci + gap + ichimoku + ...
% %        macd + on_bal_vol + rsi + stoch_osc;
%     
%     target = adx + cci + macd + stoch_osc;
% end

%% rule 1
% generate basic target if buy(i) > sell(i) etc. 
% works better than buy(i) > sell(i) + hold(i)
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

%% rule 2
% change target if there is a gap between open(i) and close(i-1) and no buy
% signal or if close(i) is below stop_loss calculated for closest potential
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

%% rules that were proposed but not used in the final version

% arfitificially reduces number of buy and sell signals and increases
% number of hold signals
% function [target] = empirRule3(target)
%     for i = 2:height(target)
%         if((target.Buy(i) == 1))% || (target.Buy(i) == 1 && target.Hold(i-1) == 1))
%             for j = i+1:height(target)
%                 if(target.Buy(j) == 1)% || target.Hold(j) == 1)
%                     target.Buy(j) = 0;
%                     target.Hold(j) = 1;
%                 else
%                     break
%                 end
%             end
%         elseif((target.Sell(i) == 1))% || (target.Sell(i) == 1 && target.Hold(i-1) == 1))
%             for j = i+1:height(target)
%                 if(target.Sell(j) == 1)% || target.Hold(j) == 1)
%                     target.Sell(j) = 0;
%                     target.Hold(j) = 1;
%                 else
%                     break
%                 end
%             end
%         end
%     end
% end

% artificially increase number of buy and sell signals
% if there are one or more hold signals between buy signals or sell signals
% change these hold signals to buy or sell respectively
% e.g.: buy, hold, hold, buy => buy, buy, buy, buy
% function [target] = empirRule4(target)
%     buy = false;
%     sell = false;
%     for i = 2:height(target)
%         if(target.Hold(i) == 1)
%             for j = i+1:height(target)
%                 if(target.Buy(j) == 1)
%                     buy = true;
%                     break;
%                 elseif(target.Sell(j) == 1)
%                     sell = true;
%                     break
%                 end
%             end
%             for j = i-1:-1:1
%                 if(target.Buy(j) == 1 && sell == true)
%                     sell = false;
%                     break;
%                 elseif(target.Sell(j) == 1 && buy == true)
%                     buy = false;
%                     break
%                 end
%             end
%             if(buy == true)
%                 target.Hold(i) = 0;
%                 target.Buy(i) = 1;
%             elseif(sell == true)
%                 target.Hold(i) = 0;
%                 target.Sell(i) = 1;
%             end
%         end
%     end
% end

%% plot and save signal graphs
% plot close and buy and sell signals, save figure
function [] = plotSignals(target, data, data_file)
    close = data.Close;
    date = data.Date;
    
    plot_title = data_file;
    plot_title = erase(plot_title, '_data.csv');
    plot_title = erase(plot_title, '_data_red.csv');
    plot_title = upper(plot_title);
    plot_title = strcat(plot_title, ' - Generated Target');
    
    figure('Name', 'Target Generation');
    title(plot_title);
    ylabel('Close Price [USD]');
    xlabel('Date');
    hold on
    plot(date, close, 'DisplayName', 'Close Price');
    buy_signals = NaN(size(close));
    sell_signals = NaN(size(close));
    hold_signals = NaN(size(close));
    for i = 1:size(close)
        if(target.Buy(i) == 1)
            buy_signals(i) = close(i);
        elseif(target.Sell(i) == 1)
            sell_signals(i) = close(i);
        else
            hold_signals(i) = close(i);
        end 
    end
    plot(buy_signals, '.g');
    plot(sell_signals, '.r');
    plot(hold_signals, '.y');
    legend('Close Price', 'Buy Signal', 'Sell Signal', 'Hold Signal');
    hold off
    filename = data_file;
    filename = erase(filename, '_data.csv');
    filename = erase(filename, '_data_red.csv');
    filename = strcat(filename, '_target_signals', '.fig');
    savefig(filename);
end