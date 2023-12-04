%% help
% compare profits gained from trading with outputs of neural networks with
% the profits gained from trading with pure technical analysis
% input: number of cycles, number of neurons, network type (all for reading
% file)
% syntax: compTechAnNeuralNetworks(num_of_cycles, num_of_neurons,
% network_type)
% network types: "shallow", "gru", "lstm1", "lstm2"
% e.g.: compTechAnNeuralNetworks(50, 32, "lstm1")
% output: comparison of OS1 and OS2 for neural networks outputs and
% technical analysis outputs

%% compares profitability of neural network outputs and pure technical analysis
function [result_strat1, result_strat2] = compTechAnNeuralNetworks(num_of_cycles, num_of_neurons, network_type)
    cryptos = ["btc", "eth", "ltc", "xmr", "xrp"];
    base_techAn1_name = '_profit_strat1_test_profit_10000_0.02.csv';
    base_techAn2_name = '_profit_strat2_test_profit_10000_0.02.csv';
    base_network1_name = '_profit_strat1_target_result_';
    base_network2_name = '_profit_strat2_target_result_';
    num_of_cycles = num2str(num_of_cycles);
    num_of_neurons = num2str(num_of_neurons);
    result_strat1 = zeros(2, numel(cryptos));
    result_strat2 = zeros(2, numel(cryptos));
    for i = 1:5
        techAn1_name = strcat(cryptos(i), base_techAn1_name);
        techAn2_name = strcat(cryptos(i), base_techAn2_name);
        techAn1 = readtable(techAn1_name);
        techAn2 = readtable(techAn2_name);
        network1_name = strcat(cryptos(i), base_network1_name , num_of_cycles, '_',...
            num_of_neurons, '_', network_type, '_10000_0.02.csv');
        network2_name = strcat(cryptos(i), base_network2_name , num_of_cycles, '_',...
            num_of_neurons, '_', network_type, '_10000_0.02.csv');
        network1 = readtable(network1_name);
        network2 = readtable(network2_name);
        result_strat1(1, i) = network1.(2)(3) - techAn1.(2)(3);
        result_strat1(2, i) = network1.(2)(3) / techAn1.(2)(3);
        result_strat2(1, i) = network2.(2)(3) - techAn2.(2)(3);
        result_strat2(2, i) = network2.(2)(3) / techAn2.(2)(3);
    end
    result_strat1 = round(result_strat1, 4);
    result_strat2 = round(result_strat2, 4);
    format short g;
end