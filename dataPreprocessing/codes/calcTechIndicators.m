% calculates technical indicators from .csv file
% inputs: Date, Open, Low, High, Close, Volume, Market Cap
% syntax: calcTechIndicators('<crypto_name>_data_pre.csv')
% e.g.: calcTechIndicators('btc_data_pre.csv')
% can calculate following ouputs: 
%   daily variation (High(t)-Low(t))
%   interday gap (Open(t)-Close(t-1))
%   interday volume change (Volume(t)-Volume(t-1)/(Volume(t-1))
%   interday close change (see interday Volume change)
%   on balance volume
%   volatility over n days (standard deviation)
%   relative strength index
%   aroon index over n days
%   bollinger bands
%   accumulation/distribution line
%   moving average convergence/divergence
%   stochastic oscillator
%   average directional movement over n days
%   ichimoku cloud
%   commodity channel index

%% calculate technical indicators
function[data_pre] = calcTechIndicators(filename)
    if(isempty(filename))
        return
    end   
    [data_pre, filename] = readData(filename);
    
    %data_pre = calcDailyVariation(data_pre);   
    data_pre = calcInterdayGap(data_pre);       
    data_pre = calcDailyVolumeChange(data_pre);
    %data_pre = calcCloseChange(data_pre);    
    data_pre = calcOnBalanceVolume(data_pre);   
    %data_pre = calcNDayVolatility(data_pre);    
    data_pre = calcRsi(data_pre);    
    data_pre = calcAroonOsc(data_pre);    
    data_pre = calcBollingerBands(data_pre);    
    data_pre = calcAccDistLine(data_pre);      
    data_pre = calcMacd(data_pre);    
    data_pre = calcStochOsc(data_pre);        
    data_pre = calcAdx(data_pre);   
    data_pre = calcIchimokuCloud(data_pre);
    data_pre = calcCci(data_pre);
           
    %get rid of nan and undesired 0 data
    cut_index = 0;
    cut_index_temp = 0;
    for i = 2:width(data_pre)
        for j = 1:50
            if(isnan(data_pre.(i)(j)))
                cut_index_temp = j;
            end
        end
        if cut_index_temp > cut_index
            cut_index = cut_index_temp;
        end
    end
    data_pre([1:cut_index+1],:) = [];
    
    writeData(data_pre, filename);         
end

%% read and write data
function[data_pre, filename] = readData(filename)
    if(isempty(filename))
        return
    end
    data_pre = readtable(filename);
    filename = erase(filename, '_data_pre.csv');
    %data_pre = readtable('btc_data_pre.csv'); %load data got by python script
    data_pre =  flipud(data_pre); %flip to from oldest to newest 
end

function[] = writeData(data_pre, filename)
    %output file
    % get rid of empty cells where indicators couldn't be calculated
    data = data_pre(53:end-26,:);
    data_suffix = '_data.csv';
    filename = strcat(filename, data_suffix);
    writetable(data, filename);    
end

%% calculate technical indicators exec functions
% daily variation
function[data_pre] = calcDailyVariation(data_pre)
    daily_var = data_pre.High - data_pre.Low; 
    data_pre = addvars(data_pre, daily_var, 'After', 'MarketCap');
end

% interday gap
function[data_pre] = calcInterdayGap(data_pre)
    %gap between close and open next day
    interday_gap = NaN(height(data_pre),1); 
    for i = 2 : height(data_pre)
        interday_gap(i) = data_pre.Open(i) - data_pre.Close(i-1);
    end
    data_pre = addvars(data_pre, interday_gap, 'After', 'MarketCap');
end

% daily volume change
function[data_pre] = calcDailyVolumeChange(data_pre)
        %day-to-day volume change
    daily_volume_change = NaN(height(data_pre),1); 
    for i = 2 : height(data_pre)
        if(data_pre.Volume(i-1)~=0)
            daily_volume_change(i) = (data_pre.Volume(i)-data_pre.Volume(i-1))...
                /data_pre.Volume(i-1);
        end
        if(data_pre.Volume(i-1)==0)
            daily_volume_change(i) = 0;
        end
    end
    data_pre = addvars(data_pre, daily_volume_change, 'After', 'MarketCap');
end

% close change
function[close_change] = calcDailyCloseChange(data_pre)
        %change in close prices
    close_change = NaN(height(data_pre),1); 
    for i = 2 : height(data_pre)
        close_change(i) = (data_pre.Close(i)-data_pre.Close(i-1))...
            /data_pre.Close(i-1);
    end
    data_pre = addvars(data_pre, close_change, 'After', 'MarketCap');
end

% on balance volume
function[data_pre] = calcOnBalanceVolume(data_pre)
    % on balance volume
    %on_balance_volume = onbalvol(btc_data_pre); %use inbuilt function
    on_balance_volume = zeros(height(data_pre),1);
    on_balance_volume(1) = 0;
    close = data_pre.Close;
    for i=2:height(data_pre)
        if(close(i) > close(i-1))
            on_balance_volume(i) = on_balance_volume(i-1) + data_pre.Volume(i);
        elseif(close(i) < close(i-1))
            on_balance_volume(i) = on_balance_volume(i-1) - data_pre.Volume(i);
        else
            on_balance_volume(i) = on_balance_volume(i-1);
        end
    end
    data_pre = addvars(data_pre, on_balance_volume, 'After', 'MarketCap');
end

% n day volatility (standard deviation)
function[data_pre] = calcNDayVolatility(data_pre)
        %volatility over n days
    n = 10;
    n_day_volat = zeros(height(data_pre),1); 
    n_day_mean = zeros(height(data_pre),1);
    interday_dif = zeros(height(data_pre),1);
    for j = n+1:height(data_pre)
        for k = j-n+1:j           
            n_day_mean(j) = n_day_mean(j) + (data_pre.Close(k)...
                - data_pre.Close(k-1));
        end
        n_day_mean(j) = n_day_mean(j) / n;
        for m =j-n+1:j
            interday_dif(m) = data_pre.Close(m)-data_pre.Close(m-1);
            n_day_volat(j) = n_day_volat(j) + (interday_dif(m) - n_day_mean(j))^2;
        end
        n_day_volat(j) = sqrt(n_day_volat(j)/n);
    end
    data_pre = addvars(data_pre, n_day_volat, 'After', 'MarketCap');
end

% relative strength index (rsi)
function[data_pre] = calcRsi(data_pre)
        %relative strength index
    rsi = rsindex(data_pre.Close, 'WindowSize', 14); 
    data_pre = addvars(data_pre, rsi, 'After', 'MarketCap');
end

% aroon oscillator
function[data_pre] = calcAroonOsc(data_pre)
    %aroon indicator over N days
    N = 25;
    hhigh_N = 0;
    llow_N = max(data_pre.Close);
    % number of periods since highest high and lowest low
    hhigh_ind = 0;
    llow_ind = 0;
    aroon_u = NaN(height(data_pre),1);
    aroon_d = NaN(height(data_pre),1);
    aroon_osc =  NaN(height(data_pre),1);
    for i = N+1:height(data_pre)
        for j = i-N:i
            if(data_pre.High(j) > hhigh_N)
                hhigh_N = data_pre.High(j);
                hhigh_ind = i - j;
            end
            if(data_pre.Low(j) < llow_N)
                llow_N = data_pre.Low(j);
                llow_ind = i - j;
            end
        end
        aroon_u(i) = ((N-hhigh_ind)/N)*100;
        aroon_d(i) = ((N-llow_ind)/N)*100;
        aroon_osc(i) = aroon_u(i) - aroon_d(i);
        hhigh_N = 0;
        llow_N = max(data_pre.Close);
        hhigh_ind = 0;
        llow_ind = 0;
    end
    data_pre = addvars(data_pre, aroon_osc,'After', 'MarketCap');  
end

% bollinger bands
function[data_pre] = calcBollingerBands(data_pre)
        %bollinger bands
    [bol_mid, bol_up, bol_low] = bollinger(data_pre.Close); 
    data_pre = addvars(data_pre, bol_low, bol_mid, bol_up,...
        'After', 'MarketCap');
end

% accumulation distribution line
function[data_pre] = calcAccDistLine(data_pre)
    %accdist line
    for i = 1 : height(data_pre)
        if data_pre.Volume(i) ~= 0
            non_zero_volume = i;
            break
        end
    end
    acc_dist_line_part = adline(data_pre(non_zero_volume:end,...
        {'Low', 'High', 'Close', 'Volume'})); %accumulation distribution line
    acc_dist_line_rem = zeros(non_zero_volume-1,1);
    acc_dist_line_rem = array2table(acc_dist_line_rem);
    acc_dist_line_rem.Properties.VariableNames = {'ADLine'};
    acc_dist_line = [acc_dist_line_rem; acc_dist_line_part];
    data_pre = addvars(data_pre, acc_dist_line.ADLine, 'After', 'MarketCap',...
        'NewVariableNames', 'acc_dist_line');
end

% moving average convergence divergence (macd)
function[data_pre] = calcMacd(data_pre)
     %moving average conv div
    [macd_line, signal_line] = macd(data_pre.Close);
    data_pre = addvars(data_pre, macd_line, signal_line, 'After', 'MarketCap');
    %plot(btc_data_pre.Date, macd_line, btc_data_pre.Date,signal_line);
end

% stochastic oscillator
function[data_pre] = calcStochOsc(data_pre)
        %stochastic oscillator
    percent_knd = stochosc(data_pre); 
    data_pre = addvars(data_pre, percent_knd.FastPercentK,...
        percent_knd.FastPercentD,'After', 'MarketCap', 'NewVariableNames',...
        {'fast_perc_k', 'fast_perc_d'});
end

% average directional index
function[data_pre] = calcAdx(data_pre)
    %average directional movement index over N days
    % N = 14 as suggested by Wilder
    N = 14;
    up_move = zeros(height(data_pre),1);
    down_move = zeros(height(data_pre),1);
    true_range = zeros(height(data_pre),1);
    pos_dir_ind = zeros(height(data_pre),1);
    neg_dir_ind = zeros(height(data_pre),1);
    
    true_range(1) = data_pre.High(1) - data_pre.Low(1);
    for i = 2:height(data_pre)
        up_move(i) = data_pre.High(i) - data_pre.High(i-1);
        down_move(i) = data_pre.Low(i-1) - data_pre.Low(i);
        true_range(i) = max(max(abs(data_pre.High(i) - data_pre.Low(i)), ...
            abs(data_pre.High(i) - data_pre.Close(i-1))), ...
            abs(data_pre.Low(i) - data_pre.Close(i-1)));
        if(up_move(i) > down_move(i))
            down_move(i) = 0;
        elseif(down_move(i) > up_move(i))
            up_move(i) = 0;
        end
        pos_dir_ind(i) = up_move(i) / true_range(i);
        neg_dir_ind(i) = down_move(i) / true_range(i);
    end
    
    avg_down_move = zeros(height(data_pre),1);
    avg_up_move = zeros(height(data_pre),1);
    avg_true_range = zeros(height(data_pre),1);
    pos_dir_ind = zeros(height(data_pre),1);
    neg_dir_ind = zeros(height(data_pre),1);
    dir_ind = zeros(height(data_pre),1);
    
    avg_down_move(N) = sum(down_move(1:N));
    avg_up_move(N) = sum(up_move(1:N));
    avg_true_range(N) = sum(true_range(1:N));
    
    pos_dir_ind(N) = avg_up_move(N) / avg_true_range(N);
    neg_dir_ind(N) = avg_down_move(N) / avg_true_range(N);
    dir_ind(N) = (abs(pos_dir_ind(N) - neg_dir_ind(N))/abs(pos_dir_ind(N) + neg_dir_ind(N))) * 100;
    
    for i = N+1:height(data_pre)
        avg_up_move(i) = avg_up_move(i-1) - (avg_up_move(i-1)/14) + up_move(i);
        avg_down_move(i) = avg_down_move(i-1) - (avg_down_move(i-1)/14) + down_move(i);
        avg_true_range(i) = avg_true_range(i-1) - (avg_true_range(i-1)/14) + true_range(i);
        pos_dir_ind(i) = (avg_up_move(i) / avg_true_range(i)) * 100;
        neg_dir_ind(i) = (avg_down_move(i) / avg_true_range(i)) * 100;
        dir_ind(i) = (abs(pos_dir_ind(i) - neg_dir_ind(i))/abs(pos_dir_ind(i) + neg_dir_ind(i))) * 100;
    end
    
    adx = zeros(height(data_pre),1);
    adx(2*N) = (1/N)*sum(dir_ind(N+1:2*N));
    for i = 2*N+1:height(data_pre)
        adx(i) = (13*adx(i-1) + dir_ind(i))/14;
    end
    
    data_pre = addvars(data_pre, adx, pos_dir_ind, neg_dir_ind, ...
        'After', 'MarketCap', 'NewVariableNames', {'adx', 'pos_dir_ind', 'neg_dir_ind'});
end

% ichimoku cloud
function[data_pre] = calcIchimokuCloud(data_pre)
    %ichimoku cloud
    conv_line_n = 9;
    base_line_n = 26;
    lead_span_n = 52;
    lead_span_a = zeros(height(data_pre),1);
    lagg_span = zeros(height(data_pre),1);
    ichimoku_cloud = zeros(height(data_pre),1);
    %conversion, base line, lead span b
    conv_line = calcIchimokuCloudLine(data_pre, conv_line_n);
    base_line = calcIchimokuCloudLine(data_pre, base_line_n);
    lead_span_b = calcIchimokuCloudLine(data_pre, lead_span_n);
    
    %lead span a
    for i = base_line_n:height(data_pre)
        lead_span_a(i) = (conv_line(i) + base_line(i))/2;
    end
    % colored cloud
    for i = lead_span_n:height(data_pre)
       ichimoku_cloud(i) =  lead_span_a(i) - lead_span_b(i);
    end
    %lagging span
    for i = 1:height(data_pre)-base_line_n
        lagg_span(i) = data_pre.Close(i+base_line_n);
    end  
    data_pre = addvars(data_pre, lead_span_a, lead_span_b, lagg_span,...
        'After', 'MarketCap');
end

% calculates n day High - n day Low and corresponding line for ichimoku
% cloud
function[line] = calcIchimokuCloudLine(data, temp_line_n)
    per_high = zeros(height(data),1);
    per_low = zeros(height(data),1);
    line = zeros(height(data),1);
    for i = temp_line_n:height(data)
        per_high_temp = data.High(i);
        per_low_temp = data.Low(i);
        for j = i-temp_line_n+1:i
            if(data.Low(j) < per_low_temp)
                per_low_temp = data.Low(j);
            end
            if(data.High(j) > per_high_temp)
               per_high_temp = data.High(j); 
            end
        end
        per_high(i) = per_high_temp;
        per_low(i) = per_low_temp;
        line(i) = (per_high(i) + per_low(i))/2;
    end
end

% commodity channel index (cci)
function[data_pre] = calcCci(data_pre)
    N = 20; 
    typ_price = NaN(height(data_pre),1);
    
    % typical price moving average over 20 days
%     typ_price_temp = 0;
%     for i = N:height(data_pre)
%        for j = i-N+1:i
%            typ_price_temp = typ_price_temp + (data_pre.High(j) + data_pre.Low(j) + ...
%                data_pre.Close(j)) / 3;
%        end
%        typ_price(i) = typ_price_temp / N;
%        typ_price_temp = 0;
%     end
    
    % I see it as better to use one day typical price instead of period
    % moving average as above because I'm not sure about the usefulness of
    % using prices as far away as 20 days back
    for i = 1:height(data_pre)
        typ_price(i) = (data_pre.High(i) + data_pre.Low(i) + ...
            data_pre.Close(i)) / 3;
    end
    
    mov_av = NaN(height(data_pre),1);
    mov_av_temp = 0;
    for i = N:height(data_pre)
       for j = i-N+1:i
          mov_av_temp = mov_av_temp + typ_price(j);
       end
       mov_av(i) = mov_av_temp / N;
       mov_av_temp = 0;
    end
    
    % https://www.investopedia.com/terms/c/commoditychannelindex.asp
    mean_dev = NaN(height(data_pre),1);
    mean_dev_temp = 0;
    for i = 2*N:height(data_pre)
       for j = i-N+1:i
          mean_dev_temp = mean_dev_temp + abs(typ_price(j) - mov_av(j)); 
       end
       mean_dev(i) = mean_dev_temp / N;
       mean_dev_temp = 0;
    end
    
    cci = NaN(height(data_pre),1);
    for i = 2*N:height(data_pre)
        cci(i) = (typ_price(i) - mov_av(i)) / (0.015 * mean_dev(i));
    end
    
    data_pre = addvars(data_pre, cci, 'After', 'MarketCap');
end