%% help
% trains, verifies and tests neural network through cycle for 1 to max
% number of neurons
% now only used as exec function of network_cycle
% input: crypto's name (3 letters), total number of cycles, maximum number of neurons
% current cycle number
% syntax: neuralNetwork("<crypto_name>", num_of_cycles, max_no_of_neurons, cur_cycle)
% e.g.: neuralNetwork("btc", 10, 64, 1)
% output: performance of best verified net on test data, output test target

%% neural network
function [num_test_best, best_net, perf_test_max, true_pos, false_pos, true_neg, false_neg, ...
    true_pos_rate, false_pos_rate, true_neg_rate, false_neg_rate, ...
    pos_pred_val, false_disc_rate, neg_pred_val, false_omis_rate,...
    accuracy, matthews_corr_coeff, rk_stat, target_test_result] = deepNeuralNetwork(network_type, crypto_name, num_of_cycles, max_num_of_neurons, cur_cycle)
    
    %read train, verif, test inputs and targets
    [input_train, target_train, input_verif, target_verif, input_test, target_test] = readData(crypto_name);    
    
    perf_verif = zeros(max_num_of_neurons,3);  
    perf_verif_max = 0;
    best_verif_nets = cell(max_num_of_neurons,2);
    k = 1;
    
    % define neural networks in cycle from 1 to max num of neurons
    num_of_inputs = 11;
    num_of_clases = 3;
    for i = 1:max_num_of_neurons
        num_of_neurons = i;
       
        if(strcmp(network_type, "gru")) 
            layers = [...
            sequenceInputLayer(num_of_inputs)
            gruLayer(num_of_neurons)
            fullyConnectedLayer(num_of_clases)
            softmaxLayer
            classificationLayer];
        elseif(strcmp(network_type, "lstm2"))
            layers = [...
            sequenceInputLayer(num_of_inputs)
            lstmLayer(num_of_neurons)
            lstmLayer(ceil(num_of_neurons / 2))
            fullyConnectedLayer(num_of_clases)
            softmaxLayer
            classificationLayer];
        else
            layers = [...
            sequenceInputLayer(num_of_inputs)
            lstmLayer(num_of_neurons)
            fullyConnectedLayer(num_of_clases)
            softmaxLayer
            classificationLayer];
        end
        
    
        options = trainingOptions('adam', ...
        'MaxEpochs', 50, ...
        'InitialLearnRate', 0.1, ...
        'GradientThreshold', 2, ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropPeriod', 30, ...
        'LearnRateDropFactor', 0.001, ...
        'MiniBatchSize', 30, ...
        'Verbose',0, ...
        'ValidationData', {input_verif, target_verif}, ...
        'ValidationFrequency', 5, ...
        'ValidationPatience', 5); % ...
        %'Plots', 'training-progress');
               
        net = trainNetwork(input_train, target_train, layers, options);
        % it is not desirable to put this into method because we must pass
        % i as argument to find best number of neurons. we would then have
        % to call this method as i = 1 when testing performance of test
        % target which would make the best number of neurons 1, instead of
        % real number. it's better to just have it like this.
        target_verif_result = classify(net, input_verif);
        for j = 1:size(target_verif_result,2)
            if(target_verif_result(j) == target_verif(j))
                perf_verif(i,2) = perf_verif(i,2) + 1;
            end
        end
        perf_verif(i,1) = i;
        perf_verif(i,3) = perf_verif(i,2) / size(target_verif, 2);
        if (perf_verif(i, 3) >= perf_verif_max)            
            if(perf_verif(i, 3) > perf_verif_max)
                perf_verif_max = perf_verif(i,3);
                best_verif_nets = cell(max_num_of_neurons-i+1,2);
                k = 1;
                best_verif_nets{k,1} = i;
                best_verif_nets{k,2} = net;
                k = k + 1;
            else
                perf_verif_max = perf_verif(i,3);
                best_verif_nets{k,1} = i;
                best_verif_nets{k,2} = net;
                k = k + 1;
                %num_verif_best = i;
            end
        end
        
        % display verification stats
        stat_disp_verif = ['Cycle: ', num2str(cur_cycle), '/', num2str(num_of_cycles),...
            ', Net: ', num2str(i), '/' , num2str(max_num_of_neurons), ', Verif. perf.:', num2str(perf_verif(i, 3))];
        disp(stat_disp_verif);
    end
    
    % test best verified net
    perf_test_max = 0;
    best_verif_nets = best_verif_nets(1:k-1,:);
    perf_test = zeros(k-1,3);
    for i = 1:k-1
        net = best_verif_nets{i,2};
        target_test_result_temp = classify(net, input_test);
        for j = 1:size(target_test_result_temp,2)
            if(target_test_result_temp(j) == target_test(j))
                perf_test(i,2) = perf_test(i,2) + 1;
            end
        end
        perf_test(i,1) = best_verif_nets{i,1};
        perf_test(i,3) = perf_test(i,2) / size(target_test, 2);
        if (perf_test(i, 3) > perf_test_max)
            perf_test_max = perf_test(i,3);
            best_net = net;
            num_test_best = best_verif_nets{i, 1};
            target_test_result = target_test_result_temp;
        end
    end
        
    % display test stats
    stat_disp_test = ['Cycle: ', num2str(cur_cycle), '/', num2str(num_of_cycles), ...
        ', Best net: ', num2str(num_test_best), '/', num2str(max_num_of_neurons), ', Test. perf.:', num2str(perf_test_max)];
    disp(stat_disp_test);
    
    target_test = convTarToDouble(target_test);
    target_test_result = convTarToDouble(target_test_result);
    
    [true_pos, false_pos, true_neg, false_neg, ...
        true_pos_rate, false_pos_rate, true_neg_rate, false_neg_rate, ...
    pos_pred_val, false_disc_rate, neg_pred_val, false_omis_rate, ...
    accuracy, matthews_corr_coeff, rk_stat] = classEvaluator(target_test, target_test_result);

    %writeData(crypto_name, perf_verif, target_test_result);
end
%% read and write data
function [input_train, target_train, input_verif, target_verif, input_test, target_test] = readData(crypto_name)
    filename_base = crypto_name;
    
    input_train_file = strcat(filename_base, "_data_train.csv");
    input_verif_file = strcat(filename_base, "_data_verif.csv");
    input_test_file = strcat(filename_base, "_data_test.csv");
    target_train_file = strcat(filename_base, "_target_train.csv");
    target_verif_file = strcat(filename_base, "_target_verif.csv");
    target_test_file = strcat(filename_base, "_target_test.csv");
    
    input_train = readtable(input_train_file);
    input_train = table2array(input_train)';
    
    target_train = readtable(target_train_file);
    target_train = convTarToCats(target_train);
    
    input_verif = readtable(input_verif_file);
    input_verif = table2array(input_verif)';
    
    target_verif = readtable(target_verif_file);
    target_verif = convTarToCats(target_verif);
    
    input_test = readtable(input_test_file);
    input_test = table2array(input_test)';
    
    target_test = readtable(target_test_file);
    target_test = convTarToCats(target_test);
end

% write data not used as deep neural network is a part of a larger cycle
% function [] = writeData(crypto_name, perf_test, target_test_result)
%     filename_base = crypto_name;
%     perf_test = array2table(perf_test);
%     perf_test.Properties.VariableNames = {'No. of neurons', 'Pred. perf - abs', 'Pred. performance - rel'};
%     perf_test = sortrows(perf_test, 3, 'descend');
%     target_test_result = target_test_result';
%     target_test_result = array2table(target_test_result);
%     target_test_result.Properties.VariableNames = {'Buy', 'Hold', 'Sell'};
%     
%     perf_file = strcat(filename_base, '_network_perf.csv');
%     target_result_file = strcat(filename_base, '_target_result.csv');
%     writetable(perf_test, perf_file);
%     writetable(target_test_result, target_result_file);
% end

%% convert targets to categorical vector and back to decision matrix
function [target] = convTarToCats(target_pre)
    target = table2array(target_pre);
    target_temp = NaN(size(target, 1), 1);
    for i = 1:size(target, 1)
       for j = 1:3
           if target(i,1) == 1
               target_temp(i) = 1;
           elseif target(i,2) == 1
               target_temp(i) = 0;
           elseif target(i,3) == 1
               target_temp(i) = -1;
           end
       end
    end
    target = target_temp';
    target = categorical(target);
end

function [target] = convTarToDouble(target_pre)
    target_pre = double(target_pre);
    target = zeros(size(target_pre, 2), 3);
    for i = 1:size(target_pre, 2)
        if(target_pre(i) == 1)
            target(i, 3) = 1;
        elseif(target_pre(i) == 2)
            target(i, 2) = 1;
        elseif(target_pre(i) == 3)
            target(i, 1) = 1;
        end
    end
    target = target';
end