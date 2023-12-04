%% help
% cycle for calling neural network.
% cycles input number of times through training, veryfying and testing
% network for 1 to input max number of neurons
% input: crypto's name (three letters), number of cycles, maximum number of
% neurons
% syntax: networkCycle("<crypto_name>", no_of_cycles, max_no_of_neurons)
% e.g.: networkCycle("btc", 10, 64)
% output: .mat variable with best number of neurons, performance evaluation
% and best target for each cycle, .csv of best classified target overall

%% neural network cycle
function [result] = networkCycle(crypto_name, network_type,  num_of_cycles, max_num_of_neurons)
   result = cell(num_of_cycles, 12);  
   for cur_cycle = 1:num_of_cycles
       if(strcmp(network_type, "gru") || strcmp(network_type, "lstm1") || strcmp(network_type, "lstm2"))
           [num_best, best_net, perf_max, true_pos, false_pos, true_neg, false_neg, ...
               true_pos_rate, false_pos_rate, true_neg_rate, false_neg_rate, ...
        pos_pred_val, false_disc_rate, neg_pred_val, false_omis_rate,...
        accuracy, matthews_corr_coeff, rk_stat, target] = deepNeuralNetwork(network_type, crypto_name, num_of_cycles, max_num_of_neurons, cur_cycle);
       elseif(strcmp(network_type, "shallow"))
            [num_best, best_net, perf_max, true_pos, false_pos, true_neg, false_neg, ...
                true_pos_rate, false_pos_rate, true_neg_rate, false_neg_rate, ...
        pos_pred_val, false_disc_rate, neg_pred_val, false_omis_rate,...
        accuracy, matthews_corr_coeff, rk_stat, target] = shallowNeuralNetwork(crypto_name, num_of_cycles, max_num_of_neurons, cur_cycle);
       end
       result{cur_cycle, 1} = num_best;
       if(strcmp(network_type, "gru") || strcmp(network_type, "lstm1") || strcmp(network_type, "lstm2"))
            result{cur_cycle, 2} = best_net;
       elseif(strcmp(network_type, "shallow"))
            result{cur_cycle, 2} = 'N/A';
       end
       result{cur_cycle, 3} = perf_max;
       result{cur_cycle, 4} = true_pos;
       result{cur_cycle, 5} = false_pos;
       result{cur_cycle, 6} = true_neg;
       result{cur_cycle, 7} = false_neg;
       result{cur_cycle, 8} = true_pos_rate;
       result{cur_cycle, 9} = false_pos_rate;
       result{cur_cycle, 10} = true_neg_rate;
       result{cur_cycle, 11} = false_neg_rate;
       result{cur_cycle, 12} = pos_pred_val;
       result{cur_cycle, 13} = false_disc_rate;
       result{cur_cycle, 14} = neg_pred_val;
       result{cur_cycle, 15} = false_omis_rate;
       result{cur_cycle, 16} = accuracy;
       result{cur_cycle, 17} = matthews_corr_coeff;
       result{cur_cycle, 18} = rk_stat;
       result{cur_cycle, 19} = target;
   end
   writeData(crypto_name, network_type, num_of_cycles, max_num_of_neurons, result);
end

%% write data
function [] = writeData(crypto_name, network_type, no_of_cycles, max_no_of_neurons, result)
   result = cell2table(result);
   result.Properties.VariableNames = {'Num. of neurons', 'Net', 'Total perf.',...
       'True pos. abs.', 'False pos. abs.' 'True neg. abs.', 'False neg. abs.', ...
       'True pos. rate', 'False pos. rate', 'True neg. rate', 'False neg. rate', ...
       'Pos. pred. val.', 'False disc. rate', 'Neg. pred. val.', 'False omis. rate', ...
       'Accuracy', 'Matthews corr. coeff.', 'R3 Stat.', 'Target'};
   result = sortrows(result, 'Total perf.', 'descend');
   target_result = cell2mat(result.Target(1));
   target_result = array2table(target_result');
   target_result.Properties.VariableNames = {'Buy', 'Hold', 'Sell'};
   target_file = strcat(crypto_name, '_target_result_', num2str(no_of_cycles), '_', num2str(max_no_of_neurons), '_', network_type, '.csv');
   result_file = strcat(crypto_name, '_result_', num2str(no_of_cycles), '_', num2str(max_no_of_neurons), '_', network_type,  '.mat');
   save(result_file, 'result');
   writetable(target_result, target_file);
end