%% help
% randomly permutates the data and divides to either train, verif and test
% data/target sets or train, test data/target sets
% input: data file to divide, target file to divide, perc. of training
% data, perc. of verification data
% syntax: divideDataRand(data__red_file, target_file, train_coeff, verif_coeff)
% e.g.: divideDataRand('btc_data_red.csv', 'btc_target.csv', 0.6, 0.2)

%% divide data by rand perm
function [data_train, data_test, target_train, target_test] = divideDataRand(data_file, target_file, train_coeff, verif_coeff)
    if(isempty(data_file) || isempty(target_file))
        return
    end
    
    if(train_coeff <= 0 || verif_coeff < 0 || isempty(train_coeff) || isempty(verif_coeff))
        train_coeff = 0.6;
        verif_coeff = 0.2;
    end  
    
    [data_pre, data_vars, target_pre, target_vars] = readData(data_file, target_file);    
    train_steps = floor(train_coeff*size(data_pre, 1));
    
    % if we use train, verif, test division
    if(verif_coeff > 0)
        verif_steps = floor(verif_coeff*size(data_pre, 1));
        
        %test data and target are the last 20 percent chronologically
        target_test = target_pre(train_steps+verif_steps+1:end, :);
        data_test = data_pre(train_steps+verif_steps+1:end, :);
        data_test = array2table(data_test);
        data_test.Properties.VariableNames = data_vars;
        data_test_profit = data_test;
        target_test = array2table(target_test);
        target_test.Properties.VariableNames = target_vars;
        
        data_train_verif = data_pre(1:train_steps+verif_steps, :);
        target_train_verif = target_pre(1:train_steps+verif_steps, :);
        
        %create random permutation of training and verification data
        r = randperm(size(data_train_verif,1));
        data_train_verif = data_train_verif(r,:);
        target_train_verif = target_train_verif(r,:);
        
        data_train_verif = array2table(data_train_verif);
        data_train_verif.Properties.VariableNames = data_vars;
        
        target_train_verif = array2table(target_train_verif);
        target_train_verif.Properties.VariableNames = target_vars;
        
        data_train = data_train_verif([1:train_steps],:);
        data_verif = data_train_verif([train_steps+1:train_steps+verif_steps],:);
        
        target_train = target_train_verif([1:train_steps],:);
        target_verif = target_train_verif([train_steps+1:train_steps+verif_steps],:);
        
        data_train = removevars(data_train, {'Open', 'High', 'Low',...
                'Close', 'Volume', 'MarketCap'}); 
            
        data_verif = removevars(data_verif, {'Open', 'High', 'Low',...
                'Close', 'Volume', 'MarketCap'});  
            
        data_test = removevars(data_test, {'Open', 'High', 'Low',...
                'Close', 'Volume', 'MarketCap'});
               
        writeDataWithVerif(data_file, data_train, data_verif, data_test, ...
        data_test_profit, target_train, target_verif, target_test, train_steps, verif_steps);
    else % if we use train, test division
        r = randperm(size(data_pre,1));
    
        data_pre = data_pre(r,:);
        target_pre = target_pre(r,:);
        
        data_pre = array2table(data_pre);
        data_pre.Properties.VariableNames = data_vars;
        target_pre = array2table(target_pre);
        target_pre.Properties.VariableNames = target_vars;
        
        data_train = data_pre([1:train_steps],:);
        data_test = data_pre([train_steps+1:height(data_pre)],:);
        data_test_profit = data_pre([train_steps+1:height(data_pre)],:);
        
        % indices of test data must be saved so that we can later rearrange
        % the test data back to chronological order and test profits
        r_test = array2table(r(:,[train_steps+1:height(data_pre)])');
        r_test.Properties.VariableNames = {'Index'};
        
        data_train = removevars(data_train, {'Open', 'High', 'Low',...
                'Close', 'Volume', 'MarketCap'});
        data_test = removevars(data_test, {'Open', 'High', 'Low',...
                'Close', 'Volume', 'MarketCap'});
            
        target_train = target_pre([1:train_steps],:);
        target_test = target_pre([train_steps+1:height(target_pre)],:);

        writeDataWithoutVerif(data_file, data_train, data_test, ...
        data_test_profit, target_train, target_test, r_test)
    end   
end
 
%% read and write data
function [data_pre, data_vars, target_pre, target_vars] = readData(data_file, target_file)
    data_pre = readtable(data_file);
    data_pre = data_pre(:, 2:end);
    data_vars = data_pre.Properties.VariableNames;
    data_pre = table2array(data_pre);
    
    target_pre = readtable(target_file);
    target_vars = target_pre.Properties.VariableNames;
    target_pre = table2array(target_pre);
end

function [] = writeDataWithVerif(data_file, data_train, data_verif, data_test, ...
    data_test_profit, target_train, target_verif, target_test, train_steps, verif_steps)
    filename_base = erase(data_file, '_data_red.csv');

    tech_an_suffix = '_dec_tech_an_full.csv';
    tech_an_filename = strcat(filename_base, tech_an_suffix);
    tech_an = readtable(tech_an_filename);
    tech_an = tech_an(train_steps+verif_steps+1:end, :);
    tech_an_test_profit_suffix = '_dec_tech_an_test_profit.csv';
    tech_an_test_profit_filename = strcat(filename_base, tech_an_test_profit_suffix);
    writetable(tech_an, tech_an_test_profit_filename);

    data_train_suffix = '_data_train.csv';
    data_verif_suffix = '_data_verif.csv';
    data_test_suffix = '_data_test.csv';
    data_test_profit_suffix = '_data_test_profit.csv';
    target_train_suffix = '_target_train.csv';
    target_verif_suffix = '_target_verif.csv';
    target_test_suffix = '_target_test.csv';

    data_train_filename = strcat(filename_base, data_train_suffix);
    data_verif_filename = strcat(filename_base, data_verif_suffix);
    data_test_filename = strcat(filename_base, data_test_suffix);
    data_test_profit_filename = strcat(filename_base, data_test_profit_suffix);
    target_train_filename = strcat(filename_base, target_train_suffix);
    target_verif_filename = strcat(filename_base, target_verif_suffix);
    target_test_filename = strcat(filename_base, target_test_suffix);
    
    writetable(data_train, data_train_filename);
    writetable(data_verif, data_verif_filename);
    writetable(data_test, data_test_filename);
    writetable(data_test_profit,  data_test_profit_filename);
    writetable(target_train, target_train_filename);
    writetable(target_verif, target_verif_filename);
    writetable(target_test, target_test_filename);
end

function [] = writeDataWithoutVerif(data_file, data_train, data_test, ...
    data_test_profit, target_train, target_test, r_test)
    filename_base = erase(data_file, '_data.csv');
    data_train_suffix = '_data_train.csv';
    data_test_suffix = '_data_test.csv';
    data_test_profit_suffix = '_data_test_profit.csv';
    target_train_suffix = '_target_train.csv';
    target_test_suffix = '_target_test.csv';
    r_test_suffix = '_test_indices.csv';

    data_train_filename = strcat(filename_base, data_train_suffix);
    data_test_filename = strcat(filename_base, data_test_suffix);
    data_test_profit_filename = strcat(filename_base, data_test_profit_suffix);
    target_train_filename = strcat(filename_base, target_train_suffix);
    target_test_filename = strcat(filename_base, target_test_suffix);
    r_test_filename = strcat(filename_base, r_test_suffix);

    writetable(data_train, data_train_filename);
    writetable(data_test, data_test_filename);
    writetable(data_test_profit,  data_test_profit_filename);
    writetable(target_train, target_train_filename);
    writetable(target_test, target_test_filename);
    writetable(r_test, r_test_filename);
end