%% help
% trains, verifies and tests neural network through cycle for 1 to max
% number of neurons
% input: crypto's name (3 letters), maximum number of neurons
% syntax: neural_network("<crypto_name>", max_no_of_neurons)
% e.g.: neural_network("btc", 64)
% output: performance of best verified net on test data, output test target

%% net
% trains, verify, test neural network
function [num_test_best, best_net, perf_test_max, true_pos, false_pos, true_neg, false_neg, ...
    true_pos_rate, false_pos_rate, true_neg_rate, false_neg_rate, ...
    pos_pred_val, false_disc_rate, neg_pred_val, false_omis_rate, ...
    accuracy, matthews_corr_coeff, rk_stat, target_test_result] = shallowNeuralNetwork(crypto_name, num_of_cycles, max_num_of_neurons, cur_cycle)

    [input_train, target_train, input_verif, target_verif, input_test, target_test] = load_data(crypto_name);
    
    perf_verif = zeros(max_num_of_neurons,3);
    perf_verif_max = 0;
    best_verif_nets = cell(max_num_of_neurons,2);
    k = 1;
    
    %train network, verify and select best network
    for i = 1:max_num_of_neurons
        net = patternnet(i);
        net = trainrp(net,input_train,target_train);     
        target_verif_result = net(input_verif);       
        
        for j = 1:size(target_verif_result,2)
            [val, ind] = max(target_verif_result(:,j));
            for l = 1:3
                target_verif_result(l, j) = 0; 
            end
            if(val > 0.5)
                target_verif_result(ind, j) = 1;
            else
               target_verif_result(2, j) = 1;
            end
            [~, ind] = max(target_verif_result(:,j));
            if(target_verif_result(ind, j) == target_verif(ind,j))
                perf_verif(i,2) = perf_verif(i,2) + 1;
            end
            %perf(i, 3) = perf(i,2) / j;
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
        
        stat_disp_verif = ['Cycle: ', num2str(cur_cycle), '/', num2str(num_of_cycles),...
            ', Net: ', num2str(i), '/' , num2str(max_num_of_neurons), ', Verif. perf.:', num2str(perf_verif(i, 3))];
        disp(stat_disp_verif);
    end
    
    % test best verified network
    perf_test_max = 0;
    best_verif_nets = best_verif_nets(1:k-1,:);
    perf_test = zeros(k-1,3);
    for i = 1:k-1
        net = best_verif_nets{i,2};
        target_test_result_temp = net(input_test);
        for j = 1:size(target_test_result_temp,2)
            [val, ind] = max(target_test_result_temp(:,j));
            for l = 1:3
                target_test_result_temp(l, j) = 0; 
            end
            if(val > 0.5)
                target_test_result_temp(ind, j) = 1;
            else
               target_test_result_temp(2, j) = 1;
            end
            [~, ind] = max(target_test_result_temp(:,j));
            if(target_test_result_temp(ind, j) == target_test(ind,j))
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
                
   [true_pos, false_pos, true_neg, false_neg, ...
        true_pos_rate, false_pos_rate, true_neg_rate, false_neg_rate, ...
    pos_pred_val, false_disc_rate, neg_pred_val, false_omis_rate, ...
    accuracy, matthews_corr_coeff, rk_stat] = classEvaluator(target_test, target_test_result);

    %write_data(crypto_name, perf_test, target_test_result);
end

%% load and write data
function [input_train, target_train, input_verif, target_verif, input_test, target_test] = load_data(crypto_name)
    filename_base = crypto_name;
    
    input_train_file = strcat(filename_base, "_data_train.csv");
    input_verif_file = strcat(filename_base, "_data_verif.csv");
    input_test_file = strcat(filename_base, "_data_test.csv");
    target_train_file = strcat(filename_base, "_target_train.csv");
    target_verif_file = strcat(filename_base, "_target_verif.csv");
    target_test = strcat(filename_base, "_target_test.csv");
    
    input_train = readtable(input_train_file);
    input_train = table2array(input_train)';
    target_train = table2array(readtable(target_train_file))';
    input_verif = readtable(input_verif_file);
    input_verif = table2array(input_verif)';
    target_verif = table2array(readtable(target_verif_file))';
    input_test = readtable(input_test_file);
    input_test = table2array(input_test)';
    target_test = table2array(readtable(target_test'))';
end

% write data funciton not used as the shallow neural networks is a part of a
% larger cycle
% function [] = write_data(crypto_name, perf_test, target_test_result)
%     filename_base = crypto_name;
%     perf_test = array2table(perf_test);
%     perf_test.Properties.VariableNames = {'No. of neurons', 'Pred. perf - abs', 'Pred. performance - rel'};
%     perf_test = sortrows(perf_test, 3, 'descend');
%     target_test_result = target_test_result';
%     target_test_result = array2table(target_test_result);
%     target_test_result.Properties.VariableNames = {'Buy', 'Hold', 'Sell'};
%     %target_test = array2table(target_test');
%     %target_test.Properties.VariableNames = {'Buy', 'Hold', 'Sell'};
%     
%     perf_file = strcat(filename_base, '_network_perf.csv');
%     target_result_file = strcat(filename_base, '_target_result.csv');
%     writetable(perf_test, perf_file);
%     writetable(target_test_result, target_result_file);
% end