%% help
% evaluates classification results for all cryptos
% input: number of cycles, number of neurons, network type
% syntax: classEvaluatorFull(num_of_cycles, num_of_neurons, network_type);
% network types: "shallow", "gru", "lstm1", "lstm2"
% e.g.: classEvaluatorFull(50, 32, "lstm1");
% output: table with classification characteristics for all cryptos and
% input network type


%% evaluate classification results for all cryptos
function [] = classEvaluatorFull(num_of_cycles, num_of_neurons, network_type)
    cryptos = ["btc", "eth", "ltc", "xmr", "xrp"];
    num_of_cycles = num2str(num_of_cycles);
    num_of_neurons = num2str(num_of_neurons);
    base_data_filename = strcat('_result_', num_of_cycles, '_', ...
        num_of_neurons,'_', network_type, '.mat');
    for i = 1:5
        filename = strcat(cryptos(i), base_data_filename);
        [num_of_neurons_avg, tpr_avg, fpr_avg, tnr_avg, fnr_avg, ppv_avg, fdr_avg, npv_avg, for_avg, ...
            acc_avg, mcc_avg, r3_avg] = evalClassification(filename, num_of_cycles);
        writeData(cryptos(i), num_of_cycles, num_of_neurons, network_type, ...
            num_of_neurons_avg, tpr_avg, fpr_avg, tnr_avg, fnr_avg, ppv_avg, fdr_avg,...
            npv_avg, for_avg, acc_avg, mcc_avg, r3_avg);
    end
end

%% write data
function [] = writeData(crypto_name, num_of_cycles, num_of_neurons, network_type, ...
    num_of_neurons_avg, tpr_avg, fpr_avg, tnr_avg, fnr_avg, ppv_avg, fdr_avg,...
    npv_avg, for_avg, acc_avg, mcc_avg, r3_avg)

    filename = strcat(crypto_name, '_classEval_',num_of_cycles, '_',...
        num_of_neurons, '_', network_type, '.csv');
    
    % no point in showing average of average
    tpr_avg(2) = [];
    fpr_avg(2) = [];
    tnr_avg(2) = [];
    fnr_avg(2) = [];
    
    % table creation
    data_out = zeros(42, 1);
    data_out(1, 1) =  num_of_neurons_avg;
    data_out(2, 1) = r3_avg;
    for i = 3:size(data_out, 1)
        k = mod(i-3, 4) + 1;
        if(i <= 6)
            data_out(i, 1) = mcc_avg(1, k);
        elseif(i >= 7 && i <= 10)
            data_out(i, 1) = acc_avg(1, k);
        elseif(i >= 11 && i <= 14)
            data_out(i, 1) = ppv_avg(1, k);
        elseif(i >= 15 && i <= 18)
            data_out(i, 1) = fdr_avg(1, k);
        elseif(i >= 19 && i <= 22)
            data_out(i, 1) = npv_avg(1, k);
        elseif(i >= 23 && i <= 26)
            data_out(i, 1) = for_avg(1, k);
        elseif(i >= 27 && i <= 30)
            data_out(i, 1) = tpr_avg(1, k);
        elseif(i >= 31 && i <= 34)
            data_out(i, 1) = fpr_avg(1, k);
        elseif(i >= 35 && i <= 38)
            data_out(i, 1) = tnr_avg(1, k);
        else
            data_out(i, 1) = fnr_avg(1, k);
        end
    end
    
    data_out(2:end, 1) = round(data_out(2:end, 1), 4);
    format short g;
    data_out = array2table(data_out);
    data_out.Properties.VariableNames = crypto_name;
    data_out.Properties.RowNames = {'Num. of neurons avg.', 'R3 avg.', 'MCC full avg.', 'MCC buy avg.', ...
        'MCC hold avg.', 'MCC sell avg.', 'ACC full avg.', 'ACC buy avg.', ...
        'ACC hold avg.', 'ACC sell avg.', 'PPV full avg.', 'PPV buy avg.', ...
        'PPV hold avg.', 'PPV sell avg.', 'FDR full avg.', 'FDR buy avg.', ...
        'FDR hold avg.', 'FDR sell avg.', 'NPV full avg.', 'NPV buy avg.', ...
        'NPV hold avg.', 'NPV sell avg.', 'FOR full avg.', 'FOR buy avg.', ...
        'FOR hold avg.', 'FOR sell avg.', 'TPR full avg.', 'TPR buy avg.', ...
        'TPR hold avg.', 'TPR sell avg.', 'FPR full avg.', 'FPR buy avg.', ...
        'FPR hold avg.', 'FPR sell avg.', 'TNR full avg.', 'TNR buy avg.', ...
        'TNR hold avg.', 'TNR sell avg.', 'FNR full avg.', 'FNR buy avg.', ...
        'FNR hold avg.', 'FNR sell avg.'};
    writetable(data_out, filename, 'WriteRowNames', true);
end

%% calculate averages over number of cycles
function [num_of_neurons_avg, tpr_avg, fpr_avg, tnr_avg, fnr_avg, ppv_avg, fdr_avg, npv_avg, for_avg, ...
    acc_avg, mcc_avg, r3_avg] = evalClassification(filename, num_of_cycles)
    data = load(filename, "result");
    data = data.result;
    num_of_cycles = str2double(num_of_cycles);
    num_of_neurons_avg = round(sum(table2array(data(:, 'Num. of neurons'))) / num_of_cycles);
    r3_avg = sum(table2array(data(:, 'R3 Stat.'))) / num_of_cycles;
    mcc_full_avg = data(:, 'Matthews corr. coeff.');
    acc_full_avg = data(:, 'Accuracy');
    tpr_full_avg = data(:, 'True pos. rate');
    fpr_full_avg = data(:, 'False pos. rate');
    tnr_full_avg = data(:, 'True neg. rate');
    fnr_full_avg = data(:, 'False neg. rate');
    ppv_full_avg = data(:, 'Pos. pred. val.');
    fdr_full_avg = data(:, 'False disc. rate');
    npv_full_avg = data(:, 'Neg. pred. val.');
    for_full_avg = data(:, 'False omis. rate');
    
    mcc_avg_temp = zeros(1,4); acc_avg_temp = zeros(1,4);
    tpr_avg_temp = zeros(1,5); fpr_avg_temp = zeros(1,5);
    tnr_avg_temp = zeros(1,5); fnr_avg_temp = zeros(1,5);
    ppv_avg_temp = zeros(1,4); fdr_avg_temp = zeros(1,4);
    npv_avg_temp = zeros(1,4); for_avg_temp = zeros(1,4);
        
    for i = 1:num_of_cycles
        for j = 1:4
            mcc_avg_temp(1, j) = mcc_avg_temp(1, j) + table2array(mcc_full_avg.(1)(i, j));
            acc_avg_temp(1, j) = acc_avg_temp(1, j) + table2array(acc_full_avg.(1)(i, j));
            ppv_avg_temp(1, j) = ppv_avg_temp(1, j) + table2array(ppv_full_avg.(1)(i, j));
            fdr_avg_temp(1, j) = fdr_avg_temp(1, j) + table2array(fdr_full_avg.(1)(i, j));
            npv_avg_temp(1, j) = npv_avg_temp(1, j) + table2array(npv_full_avg.(1)(i, j));
            for_avg_temp(1, j) = for_avg_temp(1, j) + table2array(for_full_avg.(1)(i, j));
        end
        
        for k = 1:5
            tpr_avg_temp(1, k) = tpr_avg_temp(1, k) + table2array(tpr_full_avg.(1)(i, k));
            fpr_avg_temp(1, k) = fpr_avg_temp(1, k) + table2array(fpr_full_avg.(1)(i, k));
            tnr_avg_temp(1, k) = tnr_avg_temp(1, k) + table2array(tnr_full_avg.(1)(i, k));
            fnr_avg_temp(1, k) = fnr_avg_temp(1, k) + table2array(fnr_full_avg.(1)(i, k));
        end
        
        if(i == num_of_cycles)
            mcc_avg = mcc_avg_temp / num_of_cycles;
            acc_avg = acc_avg_temp / num_of_cycles;
            ppv_avg = ppv_avg_temp / num_of_cycles;
            fdr_avg = fdr_avg_temp / num_of_cycles;
            npv_avg = npv_avg_temp / num_of_cycles;
            for_avg = for_avg_temp / num_of_cycles;
            tpr_avg = tpr_avg_temp / num_of_cycles;
            fpr_avg = fpr_avg_temp / num_of_cycles;
            tnr_avg = tnr_avg_temp / num_of_cycles;
            fnr_avg = fnr_avg_temp / num_of_cycles;
        end                           
    end
end