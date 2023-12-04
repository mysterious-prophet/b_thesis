%% help
% decides buy, sell, hold strategy based technical indicators
% input: file with calculated technical indicators, indicators we wish to
% use while calculating the decision vector
% syntax: calcTechAnDecision('<cryptoName>_data.csv', {'ind1', 'ind2',...})
% indicator syntax names: accDist, adx, aroon, bollinger, cci, full, gap, ichimoku,
% macd, onBalVol, rsi, stochOsc
% NB: full gives decision for all indicators
% NB: indicators are sorted alphabetically during the calculation, as such
% program gives the same filename for e.g.: {'aroon', 'adx'}, {'adx',
% 'aroon'}
% e.g.: calcTechAnDecision('btc_data.csv, {'full'});
% output: vector of decisions that were based on the selected technical indicators

%% program
function [decision_final] = calcTechAnDecision(crypto_file, indicators)
    if(isempty(crypto_file) || isempty(indicators))
        return
    end
    
    [data, close, high, low, gap, volume_change, ...
    rsi, aroon_osc, bol_up, bol_low, acc_dist, macd, macd_signal, ...
    fast_d, fast_k, adx, pos_dir_ind, neg_dir_ind, lead_span_a, lead_span_b,...
    lagg_span, on_balance_volume, cci] = readData(crypto_file);   
    
    %decisions for indicators
    indicators = sort(indicators);
    n = numel(indicators);
    decision_final = zeros(height(data),3);
    for i = 1:n
        indicator = indicators(i);
        indicator = char(indicator);
        switch (indicator)
            case 'full'
                decision_gaps = gaps_dec_get(data, gap, volume_change); %, close);
                decision_rsi = rsi_dec_get(data, rsi);
                decision_aroon = aroon_dec_get(data, aroon_osc);
                decision_bol = bollinger_dec_get(data, bol_up, bol_low, close);
                decision_acc_dist = acc_dist_dec_get(data, acc_dist); %, close);
                decision_macd = macd_dec_get(data, macd, macd_signal);
                decision_stoch_osc = stoch_osc_dec_get(data, fast_d, fast_k);
                decision_adx = adx_dec_get(data, adx, pos_dir_ind, neg_dir_ind);
                decision_ichimoku = ichimoku_dec_get(data, lead_span_a, lead_span_b, lagg_span); %, close);
                decision_on_balance_volume = on_balance_volume_dec_get(data, on_balance_volume);
                decision_cci = cci_dec_get(data, cci);
                
                decision_final = decision_gaps + decision_rsi + decision_aroon + decision_bol...
        + decision_acc_dist + decision_macd + decision_stoch_osc + ...
        + decision_adx + decision_ichimoku + decision_on_balance_volume + decision_cci;
    
            case 'gap'
                decision_gaps = gaps_dec_get(data, gap, volume_change);
                decision_final = decision_final + decision_gaps;
            case 'rsi'
                decision_rsi = rsi_dec_get(data, rsi);
                decision_final = decision_final + decision_rsi;
            case 'aroon'
                decision_aroon = aroon_dec_get(data, aroon_osc);
                decision_final = decision_final + decision_aroon;
            case 'bollinger'
                decision_bol = bollinger_dec_get(data, bol_up, bol_low, close);
                decision_final = decision_final + decision_bol;
            case 'accDist'
                decision_acc_dist = acc_dist_dec_get(data, acc_dist);
                decision_final = decision_final + decision_acc_dist;
            case 'macd'
                decision_macd = macd_dec_get(data, macd, macd_signal);
                decision_final = decision_final + decision_macd;
            case 'stochOsc'
                decision_stoch_osc = stoch_osc_dec_get(data, fast_d, fast_k);
                decision_final = decision_final + decision_stoch_osc;
            case 'adx'
                decision_adx = adx_dec_get(data, adx, pos_dir_ind, neg_dir_ind);
                decision_final = decision_final + decision_adx;
            case 'ichimoku'
                decision_ichimoku = ichimoku_dec_get(data, lead_span_a, lead_span_b, lagg_span);
                decision_final = decision_final + decision_ichimoku;
            case 'onBalVol'
                decision_on_balance_volume = on_balance_volume_dec_get(data, on_balance_volume);
                decision_final = decision_final + decision_on_balance_volume;
            case 'cci'
                decision_cci = cci_dec_get(data, cci);
                decision_final = decision_final + decision_cci;
        end
    end
            
    decision_final = array2table(decision_final, 'VariableNames', {'Buy', 'Hold', 'Sell'});   
    writeData(crypto_file, indicators, decision_final);
end

%% read and write data
function [data, close, high, low, gap, volume_change, ...
    rsi, aroon_osc, bol_up, bol_low, acc_dist, macd, macd_signal, ...
    fast_d, fast_k, adx, pos_dir_ind, neg_dir_ind, lead_span_a, lead_span_b,...
    lagg_span, on_balance_volume, cci] = readData(crypto_file)

    data = readtable(crypto_file);

    %prices
    close = data.Close;
    high = data.High;
    low = data.Low;

    %gap with volume for analysis
    gap = data.interday_gap;
    volume_change = data.daily_volume_change;

    %rsi
    rsi = data.rsi;

    %aroon oscillator
    aroon_osc = data.aroon_osc;

    %bollinger bands
    bol_up = data.bol_up;
    bol_low = data.bol_low;

    %acc/dist line
    acc_dist = data.acc_dist_line;

    %macd
    macd = data.macd_line;
    macd_signal = data.signal_line;

    %stochastic oscillator
    fast_k = data.fast_perc_k;
    fast_d = data.fast_perc_d;

    %adx
    adx = data.adx;
    pos_dir_ind = data.pos_dir_ind;
    neg_dir_ind = data.neg_dir_ind;

    %ichimoku cloud
    lead_span_a = data.lead_span_a;
    lead_span_b = data.lead_span_b;
    lagg_span = data.lagg_span;

    %on balance volume
    on_balance_volume = data.on_balance_volume;
    
    %commodity channel index
    cci = data.cci;
end

function [] =  writeData(crypto_file, indicators, decision_final)
    filename = crypto_file;
    filename = erase(filename, '_data.csv');
    suffix = '_dec_tech_an';
    filename = strcat(filename, suffix);  
    n = numel(indicators);
    for i = 1:n
        indicator = indicators{i};
        suffix = strcat('_', indicator);
        filename = strcat(filename, suffix);
        suffix = '';
    end
    extension = '.csv';
    filename = strcat(filename, extension);
    writetable(decision_final, filename);  
end

%% decision making for technical indicators

% interday gaps
function [decision] = gaps_dec_get(data, gap, volume_change) %, close)
    %gaps factoring into decision
    decision = zeros(height(data),3);
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    %gap_sens_coef = 0.08;
    no_runaways = 0;
    n = 3;
    gap_trend = zeros(height(data),1);
    volume_trend = zeros(height(data),1);
    gap_trend_temp = 0;
    volume_trend_temp = 0;
    for i=n:size(decision)-1
        for j=i-n+1:i
           gap_trend_temp = gap_trend_temp + gap(j);
           volume_trend_temp = volume_trend_temp + volume_change(j);
        end
        gap_trend(i) = gap_trend_temp;
        volume_trend(i) = volume_trend_temp;
        gap_trend_temp = 0;
        volume_trend_temp = 0;
    end

    for i=n+2:size(decision)
       if(gap(i) > 0) %bullish gaps
           if(gap_trend(i) < 0) %if the gap trend was meanwhile cancelled by a significant gap in other direction cancel the runaways
              no_runaways = 0; 
              %decision.Hold(i) = decision.Hold(i) + 1;
           end
           if(volume_trend(i) > 0) %gaps tend to only have validity if joined with positive volume change
               if(gap_trend(i-1) < 0) %bullish breakaway gap
                   decision.Buy(i) = decision.Buy(i) + 1;             
               elseif(gap_trend(i-1) > 0) % bullish continuation/runaway gaps are weaker signals if repeated and can also signify approaching exhaustion of the trend
                   no_runaways = no_runaways + 1;
                   if(no_runaways <= 3) 
                       decision.Buy(i) = decision.Buy(i) + 1;
%                    elseif(no_runaways > 3 && gap(i)/close(i-1) < gap_sens_coef)
%                       decision.Sell(i) = decision.Sell(i) + 1;
                   else %bullish exhaustion gap
                      decision.Sell(i) = decision.Sell(i) + 1; 
                   end
               else
                   decision.Hold(i) = decision.Hold(i) + 1;    
               end
           else
               decision.Hold(i) = decision.Hold(i) + 1;
           end
       elseif(gap(i) < 0) %bearish gaps
          if(gap_trend(i) > 0)
              no_runaways = 0; 
              %decision.Hold(i) = decision.Hold(i) + 1;
          end 
          if(volume_trend(i) > 0)
               if(gap_trend(i-1) > 0) %bearish breakaway gap
                   decision.Sell(i) = decision.Sell(i) + 1;
               elseif(gap_trend(i-1) < 0) %continuation/runaway gaps are weaker signals if repeated and can also signify approaching exhaustion of the trend
                   no_runaways = no_runaways + 1;
                   if(no_runaways <= 3) 
                       decision.Sell(i) = decision.Sell(i) + 1;
%                    elseif(no_runaways > 3 && gap(i)/close(i-1) > -gap_sens_coef)
%                       decision.Buy(i) = decision.Buy(i) + 1;
                   else %exhaustion gap
                      decision.Buy(i) = decision.Buy(i) + 1; 
                   end
               else
                   decision.Hold(i) = decision.Hold(i) + 1;    
               end
          else
               decision.Hold(i) = decision.Hold(i) + 1;     
          end
       else
            decision.Hold(i) = decision.Hold(i) + 1; 
       end
    end   
    decision = table2array(decision);
end

% relative strength index (rsi)
function [decision] = rsi_dec_get(data, rsi)
    %rsi factoring into decision
    decision = zeros(height(data),3);
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    
    high = data.High;
    low = data.Low;
    close = data.Close;
    typ_price = (high + low + close)/3;
    
    n = 3;
    price_trend = zeros(height(data),1);
    rsi_trend =  zeros(height(data),1);
    price_trend_temp = 0;
    rsi_trend_temp = 0;
    for i=n+1:size(decision)-1
        for j=i-n:i-1
           price_trend_temp = price_trend_temp + (typ_price(j+1) - typ_price(j));
           rsi_trend_temp = rsi_trend_temp + (rsi(j+1) - rsi(j));
        end
        price_trend(i) = price_trend_temp;
        rsi_trend(i) = rsi_trend_temp;
        price_trend_temp = 0;
        rsi_trend_temp = 0;
    end
    
    for i=1:size(decision)
        if(rsi(i) > 70)
           decision.Sell(i) = decision.Sell(i) + 1;
        elseif(rsi(i) >= 50)
            % these two conditions are almost exact opposites, they could
            % be written in one condition but I consider it better to leave
            % this part more explicit so that other potential traders can
            % comment/uncomment a part and choose their own interpretation
            % according to Wilder - divergences
            if(price_trend(i) > 0 && rsi_trend(i) < 0)
                decision.Sell(i) = decision.Sell(i) + 1;
            % Cardwell's interpretation - reversals     
            elseif(price_trend(i) < 0 && rsi_trend(i) > 0)
                decision.Sell(i) = decision.Sell(i) + 1;
            else
                decision.Hold(i) = decision.Hold(i) + 1;
            end
        elseif(rsi(i) >= 30 && rsi(i) < 50)
            % see comment above
            % according to Wilder - divergences
            if(price_trend(i) < 0 && rsi_trend(i) > 0)
                decision.Buy(i) = decision.Buy(i) + 1;
            % Cardwell's interpretation - reversals    
            elseif(price_trend(i) > 0 && rsi_trend(i) < 0)
                 decision.Buy(i) = decision.Buy(i) + 1;
            else    
                decision.Hold(i) = decision.Hold(i) + 1;
            end
        elseif(rsi(i) < 30)
            decision.Buy(i) = decision.Buy(i) + 1;
        end
    end
    decision = table2array(decision);
end

% aroon oscillator
function [decision] = aroon_dec_get(data, aroon_osc)
    decision = zeros(height(data),3);
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    %aroon 
    for i=1:size(decision)
       if(aroon_osc(i) > 0)
            decision.Buy(i) = decision.Buy(i) + 1;
       elseif(aroon_osc(i) < 0)
            decision.Sell(i) = decision.Sell(i) + 1;
       else
           decision.Hold(i) = decision.Hold(i) + 1;
       end
    %    decision(i) = decision(i) + aroon_osc(i)/100;
    end      
    decision = table2array(decision);
end

% bollinger bands
function [decision] = bollinger_dec_get(data, bol_up, bol_low, close)
    decision = zeros(height(data),3);
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    bol_sens_coef = 0.08;
    for i=1:size(decision)
        if(close(i) >= (1 - bol_sens_coef)*bol_up(i))
            decision.Buy(i) = decision.Buy(i) + 1;
        elseif(close(i) <= (1 + bol_sens_coef)*bol_low(i))
            decision.Sell(i) = decision.Sell(i) + 1;
        else    
            decision.Hold(i) = decision.Hold(i) + 1;
        end
    end    
    decision = table2array(decision);
end

% accumulation distribution line
function [decision] = acc_dist_dec_get(data, acc_dist) %, close)
    %acc/dist line average
    decision = zeros(height(data),3);
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    n = 3;
    acc_dist_n_days = zeros(height(data),1);
    acc_dist_temp = 0;
    for i=n+1:size(decision)-1
       for j=i-n:i
          acc_dist_temp = acc_dist_temp + (acc_dist(j+1)-acc_dist(j)); 
       end
       acc_dist_n_days(i) = acc_dist_temp;
       acc_dist_temp = 0;
    end
    for i=n+1:size(decision)
        if(acc_dist_n_days(i) > acc_dist_n_days(i-1)) % && close(i) > close(i-1))
            decision.Buy(i) = decision.Buy(i) + 1;
        elseif(acc_dist_n_days(i) < acc_dist_n_days(i-1)) % && close(i) < close(i-1))
            decision.Sell(i) = decision.Sell(i) + 1;
        else    
            decision.Hold(i) = decision.Hold(i) + 1;
        end
    end   
    decision = table2array(decision);
end

% moving average convergence divergence (macd)
function [decision] = macd_dec_get(data, macd, macd_signal)
    %macd
    decision = zeros(height(data),3);
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    for i=2:size(decision)
        if(macd(i) > macd_signal(i))
            if(macd(i-1) < macd_signal(i-1) )
                decision.Buy(i) = decision.Buy(i) + 1;
            else
                if(macd(i-1) < 0 && macd(i) > 0)
                    decision.Buy(i) = decision.Buy(i) + 1;
                else
                    decision.Hold(i) = decision.Hold(i) + 1;
                end
            end
        elseif(macd(i) < macd_signal(i))
            if(macd(i-1) > macd_signal (i-1))
                decision.Sell(i) = decision.Sell(i) + 1;
            else
                if(macd(i-1) > 0 && macd(i) < 0)
                    decision.Sell(i) = decision.Sell(i) + 1;
                else
                    decision.Hold(i) = decision.Hold(i) + 1;              
                end
            end           
        else
            decision.Hold(i) = decision.Hold(i) + 1;
        end
    end  
    decision = table2array(decision);
end

% stochastic oscillator
function [decision] = stoch_osc_dec_get(data, fast_d, fast_k)
    %stochastic oscillator
    decision = zeros(height(data),3);
    close = data.Close;
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    for i=2:size(decision)
        % idenfity overbought and oversold levels (80, 20)
        % overbought
        if (fast_d(i) > 80)
            % this is seen as true signal of imminent price down move
            if(fast_k(i-1) > fast_d(i-1) && fast_k(i) < fast_d(i))
                decision.Sell(i) = decision.Sell(i) + 1;
            % overbought does not necesarilly mean that the price will
            % fall, there can be a strong trend
            else
                decision.Hold(i) = decision.Hold(i) + 1;    
            end
        %oversold
        elseif(fast_d(i) < 20)
            if(fast_k(i-1) < fast_d(i-1) && fast_k(i) > fast_d(i))
                decision.Buy(i) = decision.Buy(i) + 1;
            else
                decision.Hold(i) = decision.Hold(i) + 1;    
            end
        else
            % look for divergences
            % bearish divergence (prices soar, oscillator falls and does so below 50)
            if(close(i-1) < close(i) && fast_d(i-1) > fast_d(i) && fast_k(i) < 50)
                decision.Sell(i) = decision.Sell(i) + 1;
            % bullish divergence (prices fall, oscillator rises and does so above 50)    
            elseif(close(i-1) > close(i) && fast_d(i-1) < fast_d(i) && fast_k(i) > 50)
                decision.Buy(i) = decision.Buy(i) + 1;                
            else
                decision.Hold(i) = decision.Hold(i) + 1;
            end
        end   
    end
    decision = table2array(decision);    
end

% average directional index (adx)
function [decision] = adx_dec_get(data, adx, pos_dir_ind, neg_dir_ind)
    %adx
    decision = zeros(height(data),3);
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    for i=2:size(decision)    
        if(adx(i) > 20)
            if(pos_dir_ind(i-1) < neg_dir_ind(i-1) && pos_dir_ind(i) >= neg_dir_ind(i))
               decision.Buy(i) = decision.Buy(i) + 1;
            elseif(pos_dir_ind(i-1) > neg_dir_ind(i-1) && pos_dir_ind(i) <= neg_dir_ind(i))
               decision.Sell(i) =  decision.Sell(i) + 1;
            else
               decision.Hold(i) = decision.Hold(i) + 1;
            end 
        elseif(adx(i) < 20)
            decision.Hold(i) = decision.Hold(i) + 1;   
        end   
    end   
    decision = table2array(decision);
end

% ichimoku cloud
function [decision] = ichimoku_dec_get(data, lead_span_a, lead_span_b, lagg_span) %, close)
    %ichimoku cloud
    decision = zeros(height(data),3);
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    %ichimoku_sens_coef = 0.05;
    close = data.Close;
    for i=52:size(decision)
%         if (lead_span_a(i-1) < lead_span_b(i-1) && lead_span_a(i) > lead_span_b(i))
%            decision.Buy(i) = decision.Buy(i) + 1;
%         elseif (lead_span_b(i-1) < lead_span_a(i-1) && lead_span_b(i) > lead_span_a(i))
%             decision.Sell(i) = decision.Sell(i) + 1;
%         
% 
%         elseif(close(i) > (1+ichimoku_sens_coef)*lead_span_a(i))
%             decision.Buy(i) = decision.Buy(i) + 1;
%         elseif(close(i) < (1-ichimoku_sens_coef)*lead_span_b(i))
%             decision.Sell(i) = decision.Sell(i) + 1;
%        
% 
%         elseif(lagg_span(i) > close(i))
%             decision.Buy(i) = decision.Buy(i) + 1;
%         elseif(lagg_span(i) < close(i))
%             decision.Sell(i) = decision.Sell(i) + 1;
%             
%         else
%             decision.Hold(i) = decision.Hold(i) + 1;
%         end
        
        if(close(i) > lead_span_a(i))
            % green cloud
            if(lead_span_a(i) > lead_span_b(i))
                decision.Buy(i) = decision.Buy(i) + 1;
            else
                if(lagg_span(i) > close(i))
                    decision.Buy(i) = decision.Buy(i) + 1;
                else    
                    decision.Hold(i) = decision.Hold(i) + 1;
                end
            end
        elseif(close(i) < lead_span_a(i))
            %red cloud
            if(lead_span_a(i) < lead_span_b(i))
                decision.Sell(i) = decision.Sell(i) + 1;
            else
                if(lagg_span(i) < close(i))
                    decision.Sell(i) = decision.Sell(i) + 1;
                else
                    decision.Hold(i) = decision.Hold(i) + 1;
                end
            end
        else
            decision.Hold(i) = decision.Hold(i) + 1;
        end         
    end   
    decision = table2array(decision);
end

% on balance volume
function [decision] = on_balance_volume_dec_get(data, on_balance_volume)
    %on balance volume
    decision = zeros(height(data),3);
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    n = 3;
    on_balance_volume_n_days = zeros(height(data),1);
    on_balance_volume_temp = 0;
    for i=n:size(decision)-1
       for j=i-n+1:i
          on_balance_volume_temp = on_balance_volume_temp + (on_balance_volume(j+1) - on_balance_volume(j)); 
       end
       on_balance_volume_n_days(i) = on_balance_volume_temp;
       on_balance_volume_temp = 0;
    end
    for i=n+1:size(decision)
        if(on_balance_volume_n_days(i) > on_balance_volume_n_days(i-1))
            decision.Buy(i) = decision.Buy(i) + 1;
        elseif(on_balance_volume_n_days(i) < on_balance_volume_n_days(i-1))
            decision.Sell(i) = decision.Sell(i) + 1;
        else
            decision.Hold(i) = decision.Hold(i) + 1;
        end
    end   
    decision = table2array(decision);
end

% commodity channel index (cci)
function [decision] = cci_dec_get(data, cci)
    decision = zeros(height(data),3);
    decision = array2table(decision, 'VariableNames', {'Buy', 'Hold', 'Sell'});
    
    for i = 1:size(decision)
       if cci(i) >= 100
           decision.Buy(i) = 1;
       elseif cci(i) <= -100
           decision.Sell(i) = 1;
       else
           decision.Hold(i) = 1;
       end 
    end    
    decision = table2array(decision);
end