%% help
% calculates how congruent are indicators with the final action while
% trading
% input: trading_file with n indicators
% syntax: calcIndicCongruence('<cryptoName>_trading_<indicators>.csv')
% e.g.: calcIndicCongruence('btc_trading_full.csv')
% output: table of absolute and relative numbers of occurences when the
% given indicator is congruent with the final trading acction taken by the
% script 'profitability.m'

%% calculate indicator congruence
% find what indicators will have to be checked and iterate through them to
% get their congruence with overall decision of technical analysis
function [output] = calcIndicCongruence(trading_file)
    if(isempty(trading_file))
        return
    end
    
    output = array2table(NaN(1,1));
    indicators = getIndicators(trading_file);
    n = numel(indicators);   
    for i = 1:n
        indicator = indicators(i);
        indicator = char(indicator);
        switch (indicator)
            case 'full'
                [acc_dist_abs, acc_dist_rel] = getIndicCongruence(getFilename(trading_file, 'accDist', indicators), trading_file);
                [adx_abs, adx_rel] = getIndicCongruence(getFilename(trading_file, 'adx', indicators), trading_file);
                [aroon_abs, aroon_rel] = getIndicCongruence(getFilename(trading_file, 'aroon', indicators), trading_file);
                [bollinger_abs, bollinger_rel] = getIndicCongruence(getFilename(trading_file, 'bollinger', indicators), trading_file);
                [cci_abs, cci_rel] = getIndicCongruence(getFilename(trading_file, 'cci', indicators), trading_file);
                [gap_abs, gap_rel] = getIndicCongruence(getFilename(trading_file, 'gap', indicators), trading_file);
                [ichimoku_abs, ichimoku_rel] = getIndicCongruence(getFilename(trading_file, 'ichimoku', indicators), trading_file);
                [macd_abs, macd_rel] = getIndicCongruence(getFilename(trading_file, 'macd', indicators), trading_file);
                [on_bal_vol_abs, on_bal_vol_rel] = getIndicCongruence(getFilename(trading_file, 'onBalVol', indicators), trading_file);
                [rsi_abs, rsi_rel] = getIndicCongruence(getFilename(trading_file, 'rsi', indicators), trading_file);
                [stoch_osc_abs, stoch_osc_rel] = getIndicCongruence(getFilename(trading_file, 'stochOsc', indicators), trading_file);
    
                output = addvars(output, acc_dist_abs, acc_dist_rel, adx_abs, adx_rel, ...
                    aroon_abs, aroon_rel, bollinger_abs, bollinger_rel, ...
                    cci_abs, cci_rel, gap_abs, gap_rel, ichimoku_abs, ...
                    ichimoku_rel, macd_abs, macd_rel, on_bal_vol_abs, ...
                    on_bal_vol_rel, rsi_abs, rsi_rel, stoch_osc_abs, stoch_osc_rel);
                
            case 'gap'
                [gap_abs, gap_rel] = getIndicCongruence(getFilename(trading_file, 'gap', indicators), trading_file);
                output = addVars(output, gap_abs, gap_rel);
            case 'rsi'
                [rsi_abs, rsi_rel] = getIndicCongruence(getFilename(trading_file, 'rsi', indicators), trading_file);
                output = addvars(output, rsi_abs, rsi_rel);
            case 'aroon'
                [aroon_abs, aroon_rel] = getIndicCongruence(getFilename(trading_file, 'aroon', indicators), trading_file);
                output = addvars(output, aroon_abs, aroon_rel);
            case 'bollinger'
                [bollinger_abs, bollinger_rel] = getIndicCongruence(getFilename(trading_file, 'bollinger', indicators), trading_file);
                output = addvars(output, bollinger_abs, bollinger_rel);
            case 'accDist'
                [acc_dist_abs, acc_dist_rel] = getIndicCongruence(getFilename(trading_file, 'accDist', indicators), trading_file);
                output = addvars(output, acc_dist_abs, acc_dist_rel);
            case 'macd'
                [macd_abs, macd_rel] = getIndicCongruence(getFilename(trading_file, 'macd', indicators), trading_file);
                output = addvars(output, macd_abs, macd_rel);
            case 'stochOsc'
                [stoch_osc_abs, stoch_osc_rel] = getIndicCongruence(getFilename(trading_file, 'stochOsc', indicators), trading_file);
                output = addvars(output, stoch_osc_abs, stoch_osc_rel);
            case 'adx'
                [adx_abs, adx_rel] = getIndicCongruence(getFilename(trading_file, 'adx', indicators), trading_file);
                output = addvars(output, adx_abs, adx_rel);
            case 'ichimoku'
                [ichimoku_abs, ichimoku_rel] = getIndicCongruence(getFilename(trading_file, 'ichimoku', indicators), trading_file);
                output = addvars(output, ichimoku_abs, ichimoku_rel);
            case 'onBalVol'
                [on_bal_vol_abs, on_bal_vol_rel] = getIndicCongruence(getFilename(trading_file, 'onBalVol', indicators), trading_file);
                output = addvars(output, on_bal_vol_abs, on_bal_vol_rel);
            case 'cci'
                [cci_abs, cci_rel] = getIndicCongruence(getFilename(trading_file, 'cci', indicators), trading_file);
                output = addvars(output, cci_abs, cci_rel);
        end
    end
    output = removevars(output, {'Var1'});
    writeData(output, trading_file);
end

%% write data
function [] = writeData(output, trading_file)
    row_names = output.Properties.VariableNames;
    output = table2array(output);
    output = array2table(output.');
    output.Properties.RowNames = row_names;
%     output.Properties.RowNames = {'acc_dist_abs', 'acc_dist_rel',...
%         'adx_abs', 'adx_rel', 'aroon_abs', 'aroon_rel', 'bollinger_abs', ...
%         'bollinger_rel', 'cci_abs', 'cci_rel', 'gap_abs', 'gap_rel', ...
%         'ichimoku_abs', 'ichimoku_rel', 'macd_abs', 'macd_rel', ...
%         'on_bal_vol_abs', 'on_bal_vol_rel', 'rsi_abs', 'rsi_rel', ...
%         'stoch_osc_abs', 'stoch_osc_rel'};
    output.Properties.VariableNames = {'Value'};
    match = ["_trading", ".csv"];
    filename = erase(trading_file, match);
    suffix = '_ind_cong';
    extension = '.csv';
    filename = strcat(filename, suffix, extension);
    writetable(output, filename, 'WriteRowNames', true);
end

%% get filenames for indicators
function [filename] = getFilename(trading_file, indicator, indicators)
    n = numel(indicators);
    filename = trading_file;
    for i = 1:n
       indicator_temp = indicators(i);
       indicator_temp = char(indicator_temp);
       indicator_temp = strcat('_', indicator_temp);
       filename = erase(filename, indicator_temp);
    end
    match = ["_trading", '.csv', "_target", '_result', "_strat1", "_strat2"];
    filename = erase(filename, match);
    filename = strcat(filename, '_dec_tech_an_', indicator, '.csv');
end

%% get indicators
function [indicators] = getIndicators(trading_file)
    trading_file = convertStringsToChars(trading_file);
    indicators = trading_file;
    k = 1;
    for i = 1:length(trading_file)
        if(trading_file(i) == '_')
            k = i;
            break
        end
    end
    match = [trading_file(1:k), "trading_", ".csv"];
    indicators = erase(indicators, match);
    indicators = strsplit(indicators, '_');
    if(indicators(1) == "target" || indicators(1) == "strat1" || indicators(1) == "strat2")
        indicators{1, 1} = 'full';
        indicators(:, 2) = [];
    end
end
%% calculate indicator congruence exec function
function [abs_congruent, rel_congruent] = getIndicCongruence(decision_ind_file, trading_file)
   dec_ind = readtable(decision_ind_file);
   trading = readtable(trading_file);
   trading = table2array(trading);
   
   ind_congruence = NaN(size(trading));
   for i = 15:size(trading)
      if(trading(i) < 0 && dec_ind.Buy(i) == 1)
          ind_congruence(i) = 1;
      elseif(trading(i) > 0 && dec_ind.Sell(i) == 1)
          ind_congruence(i) = 1;
      elseif(trading(i) == 0 && dec_ind.Hold(i) == 1)
          ind_congruence(i) = 1;
      else
          ind_congruence(i) = 0;
      end
   end
   
   abs_congruent = sum(ind_congruence(15:end));
   rel_congruent = abs_congruent / (size(ind_congruence,1)-14); 
end