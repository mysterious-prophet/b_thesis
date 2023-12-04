%% help
% calculates profits for all cryptos used in this work based on input
% initial funds, input max risk coefficient, input number of cycles, input
% number of neurons, input network type
% syntax: profitAllCryptos(initial_funds, max_risk_coeff, num_of_cycles,
% num_of_neurons, network_type);
% network types: "shallow", "gru", "lstm1", "lstm2"
% e.g.: profitAllCryptos(10000, 0.02, 50, 32, "lstm1");
% output: trading and profits for all cryptos based on neural networks
% outputs for both trading strategies

%% calculate profits for all cryptos
function [] = profitAllCryptos(initial_funds, max_risk_coeff, num_of_cycles, num_of_neurons, network_type)
    cryptos = ["btc", "eth", "ltc", "xmr", "xrp"];
    base_data_filename = '_data_test_profit.csv';
    base_techAn_filename = '_dec_tech_an_test_profit.csv';
    num_of_cycles = num2str(num_of_cycles);
    num_of_neurons = num2str(num_of_neurons);
    base_target_filename = strcat('_target_result_', num_of_cycles, '_', num_of_neurons, '_', network_type, '.csv');
    for i = 1:5
        data_filename = strcat(cryptos(i), base_data_filename);
        techAn_filename = strcat(cryptos(i), base_techAn_filename);
        target_filename = strcat(cryptos(i), base_target_filename);
        execTrading(data_filename, techAn_filename, initial_funds, max_risk_coeff, 1);
        execTrading(data_filename, techAn_filename, initial_funds, max_risk_coeff, 2);
        execTrading(data_filename, target_filename, initial_funds, max_risk_coeff, 1);
        execTrading(data_filename, target_filename, initial_funds, max_risk_coeff, 2);
    end
end