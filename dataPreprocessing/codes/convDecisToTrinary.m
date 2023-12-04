%% help
% converts table of three columns into single decision vector of trinary
% values that signify the same decision. 
% input: decision file to be converted
% syntax: convDecisToTrinary(decis_file)
% e.g.: convDecisToTrinary('btc_dec_tech_an_rsi.csv')
% output: sigle vector of decisions composed of trinary values

%% convert decision to trinary
function [decis] = convDecisToTrinary(decis_file)
    [decis_pre, crypto_name] = readData(decis_file);
    decis = zeros(height(decis_pre),1);
    for i = 1:height(decis_pre)
       if(decis_pre.Buy(i) == 1)
           decis(i) = 1;
       elseif(decis_pre.Sell(i) == 1)
           decis(i) = -1;
       end
    end   
    writeData(decis, decis_file, crypto_name);
end

%% read and write data
function [decis_pre, crypto_name] = readData(dec_file)
    crypto_name = strsplit(dec_file, '_');
    crypto_name = crypto_name(1,1);
    decis_pre = readtable(dec_file);
end

function [] = writeData(decis, decis_file, crypto_name)
    filename = erase(decis_file, '.csv');
    filename = strcat(filename, '_trinary', '.csv');
    decis = array2table(decis);
    match = strcat(crypto_name, '_dec_tech_an_');
    vars = erase(decis_file, match);
    vars = erase(vars, '.csv');
    decis.Properties.VariableNames = {vars};
    writetable(decis, filename);
end