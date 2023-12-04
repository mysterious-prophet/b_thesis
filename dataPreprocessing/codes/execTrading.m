%% help
% calculates profit for given crypto and given decisions, strategy 1 or 2
% strategy 1: always buy once, then wait until sell. buy with all capital
% or until stop loss, sell all. 
% strategy 2: if there are more following buy signals, buy until you run out
% of capital, then on sell signal sell everything
% input: file with technical indicators for crypto (calculates stop loss),
% file with decisions, initial funds available, maximum tolerated risk per
% one transaction
% syntax: execTrading('<cryptoName>_data.csv',...
% <cryptoName>_dec_tech_an_<indicators>.csv', initial_funds, max_risk_coef)
% e.g. : execTrading('btc_data.csv', 'btc_dec_tech_an_full.csv', 10000, 0.02);
% output: table containing analysis of profitability of trading based on
% given decision file
% output:
% initial_funds - initial capital before trading
% max_risk_coef - maximum tolerated risk during one trading operation
% result_trade - capital at the end of period
% result_trade_netto = result_trade - initial_funds
% result_hold = close(end) - close(1);
% result_hold_netto = result_hold - initial_funds
% profit_comp_abs = result_trade - result_hold;
% profit_comp_funds_brutto = result_trade / initial_funds;
% profit_comp_rel = result_trade_netto / initial_funds;
% profit_comp_hold_brutto = result_trade / result_hold;
% profit_comp_hold_netto = result_trade_netto / result_hold;
% number of trades
% number of losses
% percentage of losses = number of losses / number of sales

%% execute trading strategy and calculate profits
function[initial_funds, max_risk_coeff, result_trade, result_trade_netto, result_hold, ...
    result_hold_netto, profit_comp_abs, profit_comp_funds_brutto,...
    profit_comp_funds_netto, profit_comp_rel, ...
    num_of_trades, avg_profit_per_trade, num_of_losses_abs, num_of_losses_rel] = execTrading (crypto_file, decision_file, initial_funds, max_risk_coeff, trading_strategy)

    if(isempty(crypto_file) || isempty(decision_file) || isempty(initial_funds) || isempty(max_risk_coeff) || isempty(trading_strategy))
        return
    end   
    if(trading_strategy ~= 1 && trading_strategy ~= 2)
        trading_strategy = 1;
    end
    if (initial_funds <= 0)
        initial_funds = 10000;
    end
    if (max_risk_coeff < 0)
        max_risk_coeff = 0.02;
    end

    [decision, close, high, low] = readData(crypto_file, decision_file);
    [average_true_range] = calcStopLossOrder(decision, high, low, close);
    
    if(trading_strategy == 1)
        [trading, result_trade, num_of_trades, num_of_sells] = execTrading1(decision, close, average_true_range, initial_funds, max_risk_coeff);
    else
        [trading, result_trade, num_of_trades, num_of_sells] = execTrading2(decision, close, average_true_range, initial_funds, max_risk_coeff);
    end
    
    [result_trade_netto, result_hold, result_hold_netto, profit_comp_abs, ...
            profit_comp_funds_brutto, profit_comp_funds_netto, profit_comp_rel, ...
            avg_profit_per_trade, num_of_losses_abs, num_of_losses_rel] = ...
            calcProfitability(initial_funds, close, trading, result_trade, num_of_sells);
        
    writeTradingData(crypto_file, decision_file, trading, trading_strategy);
    writeProfitData(crypto_file, decision_file, initial_funds, max_risk_coeff, ...
        result_trade, result_trade_netto, result_hold, result_hold_netto, ...
        profit_comp_abs, profit_comp_funds_brutto, profit_comp_funds_netto, ...
        profit_comp_rel, num_of_trades, avg_profit_per_trade, num_of_losses_abs, ...
        num_of_losses_rel, trading_strategy);
end

%% read and write data
function [] = writeTradingData(crypto_file, decision_file, trading, trading_strategy)
   filename = strtok(crypto_file, '_');
   match_1 = [filename, "_dec_tech_an", ".csv"];
   match_2 = [filename, "_target_result", ".csv"];
   indicators = erase(decision_file, match_1);
   if(trading_strategy == 1)
       suffix = '_trading_strat1';
   else
       suffix = '_trading_strat2';
   end
   filename = strcat(filename, suffix);
   suffix = indicators;
   filename = strcat(filename, suffix);
   extension = '.csv';
   filename = strcat(filename, extension);
   writematrix(trading, filename);
end

function [] = writeProfitData(crypto_file, decision_file, initial_funds, max_risk_coef, ...
    result_trade, result_trade_netto, result_hold, result_hold_netto, profit_comp_abs, ...
    profit_comp_funds_brutto, profit_comp_funds_netto, profit_comp_rel, num_of_trades, ...
    avg_profit_per_trade, num_of_losses_abs, num_of_losses_rel, trading_strategy)

    result_trade = round(result_trade);
    result_trade_netto = round(result_trade_netto);
    result_hold = round(result_hold);
    result_hold_netto = round(result_hold_netto);
    profit_comp_abs = round(profit_comp_abs);
    profit_comp_funds_brutto = round(profit_comp_funds_brutto, 4);
    profit_comp_funds_netto = round(profit_comp_funds_netto, 4);
    profit_comp_rel = round(profit_comp_rel, 4);
    avg_profit_per_trade = round(avg_profit_per_trade, 4);
    num_of_losses_rel = round(num_of_losses_rel, 4);
    format short g;
    
    an_output_table = table(initial_funds, max_risk_coef, result_trade, result_trade_netto, result_hold, result_hold_netto, profit_comp_abs, profit_comp_funds_brutto, profit_comp_funds_netto, profit_comp_rel, num_of_trades, avg_profit_per_trade, num_of_losses_abs, num_of_losses_rel);
    an_output_array = table2array(an_output_table);
    an_output_final = array2table(an_output_array.');
    an_output_final.Properties.RowNames = an_output_table.Properties.VariableNames;
    an_output_final.Properties.VariableNames = {'Value'};    
    
    %filename = crypto_file;
    filename = strtok(crypto_file, '_');
    match = [filename, "_dec_tech_an", ".csv"];
    indicators = erase(decision_file, match);
    if(trading_strategy == 1)
        suffix = '_profit_strat1';
    else
        suffix = '_profit_strat2';
    end
    filename = strcat(filename, suffix);
    suffix = indicators;
    filename = strcat(filename, suffix);
    initial_funds = strcat('_', string(initial_funds));
    max_risk_coef = strcat('_', string(max_risk_coef));
    filename = strcat(filename, initial_funds, max_risk_coef);
    extension = '.csv';
    filename = strcat(filename, extension);
    
    writetable(an_output_final, filename, 'WriteRowNames', true);
end

function[decision, close, high, low] = readData(crypto_file, decision_file)
    data = readtable(crypto_file);
    close = data.Close;
    high = data.High;
    low = data.Low;
    decision = readtable(decision_file);
end

%% calculate stop loss order for trading
function [average_true_range] =  calcStopLossOrder(decision, high, low, close)
    true_range = zeros(size(decision,1), 1);
    true_range(1) = high(1) - low(1);
    for i=2:size(decision)
       temp_1 =  abs(high(i) - low(i));
       temp_2 = abs(high(i) - close(i-1));
       temp_3 = abs(low(i) - close(i-1));
       temp_4 = [temp_1 temp_2 temp_3];
       true_range(i) = max(temp_4); 
    end
    n = 14;
    average_true_range = zeros(size(decision,1),1);
    %average_true_range(n) = sum(true_range(1:n))/n;
    average_true_range_temp = 0;
    for i=n+1:size(decision)
       for j=i-n+1:i
            average_true_range_temp = average_true_range_temp + true_range(j);
       end
       average_true_range(i) = average_true_range_temp / n;
       average_true_range_temp = 0;
       %average_true_range(i) = average_true_range(i-1) - (average_true_range(i-1)/14) + true_range(i);
    end
end

%% exec trading strategy 1
function [trading, result_trade, num_of_trades, num_of_sells] = execTrading1 (decision, close, average_true_range, initial_funds, max_risk_coef)
    trading = zeros(size(decision, 1), 1);
    % we have result_trade explicitly instead as = initial_funds +
    % sum(trading) because we use it as conditional for buying and position
    result_trade = initial_funds;
    max_risk_per_trade = result_trade * max_risk_coef;
    
    %are we holding? (script must buy then sell and repeat)
    %recond number of trade
    holding = false;
    num_of_trades = 0;
    num_of_sells = 0;
    %risk per one buy, calculated as close(i) - stop_loss
    %position_size calculated as max_risk_per_trade / trade_risk;
    position_size = 0;
    %stop loss coef in accordance with Technical analysis of stock trends,
    %Maggee is 10, however here it is empirically better to set it as low as 1
    stop_loss = 0;
    stop_loss_coef = 0.25;
    %transaction price by coef
    %trans_price_coef = 0.001;

    start_ind = 15;
    %start_ind = 4*365;
    final_ind = height(decision);
    for i = start_ind:final_ind           
        if((decision.Buy(i) > (decision.Sell(i) + decision.Hold(i))) && holding == false && i ~= final_ind) % && result_trade >= close(i))          
           %set stop loss
           stop_loss = close(i) - stop_loss_coef * average_true_range(i);
           if(stop_loss < 0)
               stop_loss = 0;
           end
           
           %buy position
		   max_risk_per_trade = result_trade * max_risk_coef;
           risk_per_trade = close(i) - stop_loss; 
           position_size = max_risk_per_trade / risk_per_trade;
           if (position_size*close(i) > result_trade)
               position_size = result_trade / (close(i)); % + trans_price_coef * close(i));
           end
           
           %change capital
           trading(i) = trading(i) - close(i)*position_size;% - close(i)*trans_price_coef;
           result_trade = result_trade - close(i)*position_size;% - close(i)*trans_price_coef;
           num_of_trades = num_of_trades + 1;
           holding = true;
           
        %if decision sell and holding or price below stop loss or on
        %last possible sell oportunity and holding then sell
        elseif(((decision.Sell(i) > (decision.Buy(i) + decision.Hold(i))) && holding == true) || (close(i) <= stop_loss && holding == true) || (i == final_ind && holding == true))
           trading(i) = trading(i) + close(i) * position_size;% - close(i) * trans_price_coef;
           result_trade = result_trade + close(i) * position_size; % - close(i) * trans_price_coef;
           stop_loss = 0;
           position_size = 0;
           num_of_trades = num_of_trades + 1;
           num_of_sells = num_of_sells + 1;
           holding = false;
       end
    end
end

%% exec trading strategy 2
function [trading, result_trade, num_of_trades, num_of_sells] = execTrading2 (decision, close, average_true_range, initial_funds, max_risk_coef)
    trading = zeros(size(decision, 1), 1);
    % we have result_trade explicitly instead as = initial_funds +
    % sum(trading) because we use it as conditional for buying and position
    result_trade = initial_funds;
    max_risk_per_trade = result_trade * max_risk_coef;
    
    %are we holding? (script must sell only if we have crypto to sell)
    %recond number of trade
    holding = false;
    num_of_trades = 0;
    num_of_sells = 0;
    %risk per one buy, calculated as close(i) - stop_loss
    %position_size calculated as max_risk_per_trade / trade_risk;
    position_size = 0;
    %stop loss coef in accordance with Technical analysis of stock trends,
    %Maggee is 10, however here it is empirically better to set it as low as 1
    stop_loss = 0;
    stop_loss_coef = 0.25;
    %transaction price by coef
    %trans_price_coef = 0.001;
    start_ind = 15;
    final_ind = height(decision);
    for i = start_ind:final_ind           
        if((decision.Buy(i) > decision.Sell(i) + decision.Hold(i)) && i ~= final_ind && result_trade > 0)%&& holding == false) % && result_trade >= close(i))
           %set stop loss
           stop_loss = close(i) - stop_loss_coef * average_true_range(i);
           if(stop_loss < 0)
               stop_loss = 0;
           end
           
           %buy position, we can theoretically buy until we run out of
           %money
		   max_risk_per_trade = result_trade * max_risk_coef;
           risk_per_trade = close(i) - stop_loss; 
           position_size_temp = max_risk_per_trade / risk_per_trade;
           if (position_size_temp*close(i) > result_trade)
               position_size_temp = result_trade / (close(i)); % + trans_price_coef * close(i));
           end
           position_size = position_size + position_size_temp;
           
           %change capital
           trading(i) = trading(i) - close(i)*position_size_temp;% - close(i)*trans_price_coef;
           result_trade = result_trade - close(i)*position_size_temp;%  - close(i)*trans_price_coef;
           num_of_trades = num_of_trades + 1;
           holding = true;
           
        %if decision sell and holding or price below stop loss or on
        %last possible sell oportunity and holding then sell
        elseif(((decision.Sell(i) > (decision.Buy(i) + decision.Hold(i))) && holding == true) || (close(i) <= stop_loss && holding == true) || (i == final_ind && holding == true))
           trading(i) = close(i) * position_size;% - close(i) * trans_price_coef;
           result_trade = result_trade + close(i) * position_size;% - close(i) * trans_price_coef;
           stop_loss = 0;
           position_size = 0;
           num_of_trades = num_of_trades + 1;
           num_of_sells = num_of_sells + 1;
           holding = false;
       end
    end
end

%% calculate profitability of used strategy
function [result_trade_netto, result_hold, result_hold_netto, profit_comp_abs, ...
            profit_comp_funds_brutto, profit_comp_funds_netto, profit_comp_rel, ...
            avg_profit_per_trade, num_of_losses_abs, num_of_losses_rel] = calcProfitability(initial_funds, close, trading, result_trade, num_of_sells)
    %result for buying as much as possible and holding strategy
    start_ind = 15;
    final_ind = size(close,1);
    
    hold_position = initial_funds / (close(start_ind)); % + close(start_ind) * trans_price_coef);
    result_hold = hold_position * close(final_ind); % - close(final_ind) * trans_price_coef;
    result_hold_netto = result_hold - initial_funds;
    
    %result for implemented trading strategy
    buy_temp = 0;
    sold_temp = 0;
    avg_profit_per_trade = 0;
    num_of_losses_abs = 0;
    for i = start_ind:final_ind
        if(trading(i) < 0)
            buy_temp  = buy_temp  + trading(i);
        elseif(trading(i) > 0)
            sold_temp = sold_temp + trading(i);
        end       
        if(sold_temp > 0)
            avg_profit_per_trade_temp = (-(sold_temp / buy_temp) - 1);
            avg_profit_per_trade = avg_profit_per_trade + avg_profit_per_trade_temp;
            if(avg_profit_per_trade_temp < 0)
                num_of_losses_abs = num_of_losses_abs + 1;
            end          
            buy_temp = 0;
            sold_temp = 0;
        end     
    end
    
    result_trade_netto = result_trade - initial_funds;
    profit_comp_abs = result_trade - result_hold;
    profit_comp_funds_brutto = result_trade / initial_funds;
    profit_comp_funds_netto = result_trade_netto / initial_funds;
    profit_comp_rel = result_trade / result_hold;    
    avg_profit_per_trade = avg_profit_per_trade / num_of_sells;
    num_of_losses_rel = num_of_losses_abs / num_of_sells;
end