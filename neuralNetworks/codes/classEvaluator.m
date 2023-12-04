%% help
% evaluates classification
% input: real generated target, predicted target
% syntax: classEvaluator(target_test, target_test_result)
% output: tables for true positive, false positive, true negative, false
% negative, positive predictive value, false discovery rate, negative
% predictive value, false omission rate

%% class evaluator
function [true_pos, false_pos, true_neg, false_neg, ...
    true_pos_rate, false_pos_rate, true_neg_rate, false_neg_rate, ...
    pos_pred_val, false_disc_rate, neg_pred_val, false_omis_rate, ...
    accuracy, matthews_corr_coeff, rk_stat] = classEvaluator(target_test, target_test_result)
    
    tar_buy_pos = sum(target_test(1 ,:));
    tar_hold_pos = sum(target_test(2 ,:));
    tar_sell_pos = sum(target_test(3, :));
    
    tar_buy_neg = size(target_test(1 ,:), 2) - tar_buy_pos;
    tar_hold_neg = size(target_test(2 ,:), 2) - tar_hold_pos;
    tar_sell_neg = size(target_test(3 ,:), 2) - tar_sell_pos;

    % numbers of predicted buys, holds, sells
    res_buy_pos = sum(target_test_result(1 ,:));
    res_hold_pos = sum(target_test_result(2 ,:));
    res_sell_pos = sum(target_test_result(3 ,:));
    
    % numbers of predicted non buys, holds, sells
    res_buy_neg = size(target_test(1 ,:), 2) - res_buy_pos;
    res_hold_neg = size(target_test(2 ,:), 2) - res_hold_pos;
    res_sell_neg = size(target_test(3 ,:), 2) - res_sell_pos;
     
    % get tp, tn, fp, fn
    [tp_buy, tp_hold, tp_sell] = calcTruePositive(target_test, target_test_result);
    [tn_buy, tn_hold, tn_sell] = calcTrueNegative(target_test, target_test_result);
    [fp_buy, fp_hold, fp_sell] = calcFalsePositive(target_test, target_test_result);
    [fn_buy, fn_hold, fn_sell] = calcFalseNegative(target_test, target_test_result);
    
    % create table, add full fot tp, fp, fn
    % full for tn makes no sense as it would be greater than number of
    % timesteps (there are at least two zeros in every timestep)
    tp_full = tp_buy + tp_hold + tp_sell;
    fp_full = fp_buy + fp_hold + fp_sell;
    fn_full = fn_buy + fn_hold + fn_sell;
    true_pos = table(tp_full, tp_buy, tp_hold, tp_sell);
    false_pos = table(fp_full, fp_buy, fp_hold, fp_sell);
    true_neg = table(tn_buy, tn_hold, tn_sell);
    false_neg = table(fn_full, fn_buy, fn_hold, fn_sell);
    
    
    %sensitivity, true positive rate
    tpr_buy = tp_buy / tar_buy_pos;
    tpr_hold = tp_hold / tar_hold_pos;
    tpr_sell = tp_sell / tar_sell_pos;
    tpr_avg = (tpr_buy + tpr_sell + tpr_hold) / 3;
    tpr_full = (tp_buy + tp_sell + tp_hold) / (tar_buy_pos +  tar_hold_pos + tar_sell_pos);
    true_pos_rate = table(tpr_full, tpr_avg, tpr_buy, tpr_hold, tpr_sell);
    
    %specificity, true negative rate
    tnr_buy = tn_buy / tar_buy_neg;
    tnr_hold = tn_hold / tar_hold_neg;
    tnr_sell = tn_sell / tar_sell_neg;
    tnr_avg = (tnr_buy + tnr_hold + tnr_sell) / 3;
    tnr_full = (tn_buy + tn_hold + tn_sell) / (tar_buy_neg + tar_hold_neg + tar_sell_neg);
    true_neg_rate = table(tnr_full, tnr_avg, tnr_buy, tnr_hold, tnr_sell);
    
    %fall out, false positive rate
    fpr_buy = fp_buy / tar_buy_neg;
    fpr_hold = fp_hold / tar_hold_neg;
    fpr_sell = fp_sell / tar_sell_neg;
    fpr_avg = (fpr_buy + fpr_hold + fpr_sell) / 3;
    fpr_full = (fp_buy + fp_hold + fp_sell) / (tar_buy_neg + tar_hold_neg + tar_sell_neg);
    false_pos_rate = table(fpr_full, fpr_avg, fpr_buy, fpr_hold, fpr_sell);
    
    %miss rate, false negative rate
    fnr_buy = fn_buy / tar_buy_pos;
    fnr_hold = fn_hold / tar_hold_pos;
    fnr_sell = fn_sell / tar_sell_pos;
    fnr_avg = (fnr_buy + fnr_hold + fnr_sell) / 3;
    fnr_full = (fn_buy + fn_hold + fn_sell) / (tar_buy_pos +  tar_hold_pos + tar_sell_pos);
    false_neg_rate = table(fnr_full, fnr_avg, fnr_buy, fnr_hold, fnr_sell);
    
    % posivite predictive value
    pos_pred_val_buy = tp_buy / res_buy_pos;
    pos_pred_val_hold = tp_hold / res_hold_pos;
    pos_pred_val_sell = tp_sell / res_sell_pos;
    pos_pred_val_avg = (pos_pred_val_buy + pos_pred_val_hold + ...
        pos_pred_val_sell) / 3;
    pos_pred_val = table(pos_pred_val_avg, pos_pred_val_buy, pos_pred_val_hold, pos_pred_val_sell);
    
    % false discovery rate
    false_disc_rate_buy = fp_buy / res_buy_pos;
    false_disc_rate_hold = fp_hold / res_hold_pos;
    false_disc_rate_sell = fp_sell / res_sell_pos;
    false_disc_rate_avg = (false_disc_rate_buy + false_disc_rate_hold + ...
        false_disc_rate_sell) / 3;
    false_disc_rate = table(false_disc_rate_avg, false_disc_rate_buy, false_disc_rate_hold, false_disc_rate_sell);
    
    % false omission rate
    false_omis_rate_buy = fn_buy / res_buy_neg;
    false_omis_rate_hold = fn_hold / res_hold_neg;
    false_omis_rate_sell = fn_sell / res_sell_neg;
    false_omis_rate_avg = (false_omis_rate_buy + false_omis_rate_hold + ...
        false_omis_rate_sell) / 3;
    false_omis_rate = table(false_omis_rate_avg, false_omis_rate_buy, false_omis_rate_hold, false_omis_rate_sell);
    
    % negative predictive value
    neg_pred_val_buy = tn_buy / res_buy_neg;
    neg_pred_val_hold = tn_hold / res_hold_neg;
    neg_pred_val_sell = tn_sell / res_sell_neg;
    neg_pred_val_avg = (neg_pred_val_buy + neg_pred_val_hold + ...
        neg_pred_val_sell) / 3;
    neg_pred_val = table(neg_pred_val_avg, neg_pred_val_buy, neg_pred_val_hold, neg_pred_val_sell);
    
    % accuracy
    acc_buy = (tp_buy + tn_buy) / (tp_buy + tn_buy + fp_buy + fn_buy);
    acc_hold = (tp_hold + tn_hold) / (tp_hold + tn_hold + fp_hold + fn_hold);
    acc_sell = (tp_sell + tn_sell) / (tp_sell + tn_sell + fp_sell + fn_sell);
    acc_avg = (acc_buy + acc_hold + acc_sell) / 3;
    accuracy = table(acc_avg, acc_buy, acc_hold, acc_sell);
    
    % matthews correlation coefficient
    mcc_buy = (tp_buy * tn_buy - fp_buy * fn_buy) / ...
        (sqrt((tp_buy + fp_buy)*(tp_buy + fn_buy)*(tn_buy + fp_buy)*(tn_buy + fn_buy)));
    mcc_hold = (tp_hold * tn_hold - fp_hold  * fn_hold) / ...
        (sqrt((tp_hold + fp_hold)*(tp_hold + fn_hold)*(tn_hold + fp_hold)*(tn_hold + fn_hold)));
    mcc_sell = (tp_sell * tn_sell - fp_sell * fn_sell) / ...
        (sqrt((tp_sell + fp_sell)*(tp_sell + fn_sell)*(tn_sell + fp_sell)*(tn_sell + fn_sell)));
    mcc_avg = (mcc_buy + mcc_sell + mcc_hold) / 3;
    
    matthews_corr_coeff = table(mcc_avg, mcc_buy, mcc_hold, mcc_sell);
    
    n = size(target_test, 2);
    rk_stat = ((tp_full * n) - (tar_buy_pos * res_buy_pos) - (tar_hold_pos * ...
        res_hold_pos) - (tar_sell_pos * res_sell_pos)) / ...
        (sqrt(n^2 - res_buy_pos^2 - res_hold_pos^2 - res_sell_pos^2) * ...
        sqrt(n^2 - tar_buy_pos^2 - tar_hold_pos^2 - tar_sell_pos^2));
    
end

%% functions for tp, tn, fp, fn
% true positive
function [tp_buy, tp_hold, tp_sell] = calcTruePositive(target_test, target_test_result)
    tp_buy = 0; tp_hold = 0; tp_sell = 0;
    for i = 1:size(target_test_result, 2)
        if(target_test_result(1, i) == 1 && target_test(1, i) == 1)
            tp_buy = tp_buy + 1;
        elseif(target_test_result(3, i) == 1 && target_test(3, i) == 1) 
            tp_sell = tp_sell + 1;
        elseif(target_test_result(2, i) == 1 && target_test(2, i) == 1)
            tp_hold = tp_hold + 1;
        end
    end
end

% true negative
function [tn_buy, tn_hold, tn_sell] = calcTrueNegative(target_test, target_test_result)
    tn_buy = 0; tn_hold = 0; tn_sell = 0;
    for i = 1:size(target_test_result, 2)
        if(target_test_result(1, i) == 0 && target_test(1, i) == 0)
            tn_buy = tn_buy + 1;
        end
        if(target_test_result(3, i) == 0 && target_test(3, i) == 0)
            tn_sell = tn_sell + 1;
        end
        if(target_test_result(2, i) == 0 && target_test(2, i) == 0)
            tn_hold = tn_hold + 1;
        end
    end
end

% false positive
function [fp_buy, fp_hold, fp_sell] = calcFalsePositive(target_test, target_test_result)
    fp_buy = 0; fp_hold = 0; fp_sell = 0;
    for i = 1:size(target_test_result, 2)
        if(target_test_result(1, i) == 1 && target_test(1, i) == 0)
            fp_buy = fp_buy + 1;
        elseif(target_test_result(3, i) == 1 && target_test(3, i) == 0)
            fp_sell = fp_sell + 1;
        elseif(target_test_result(2, i) == 1 && target_test(2, i) == 0)
            fp_hold = fp_hold + 1;
        end
    end
end

% false negative
function [fn_buy, fn_hold, fn_sell] = calcFalseNegative(target_test, target_test_result)
    fn_buy = 0; fn_hold = 0; fn_sell = 0;
    for i = 1:size(target_test_result, 2)
        if(target_test_result(1, i) == 0 && target_test(1, i) == 1)
            fn_buy = fn_buy + 1;
        elseif(target_test_result(3, i) == 0 && target_test(3, i) == 1)
            fn_sell = fn_sell + 1;
        elseif(target_test_result(2, i) == 0 && target_test(2, i) == 1)
            fn_hold = fn_hold + 1;
        end
    end
end