%% help
% trains, validates, tests neural networks of input type. saves best nets
% and their characterictics (classEvaluator.m)
% input: network type, number of cycles, number of neurons
% syntax: networkCycleAllCryptos(network_type, num_of_cycles,
% num_of_neurons);
% network types: "shallow", "gru", "lstm1", "lstm2"
% e.g.: networkCycleAlCryptos("lstm1", 50, 32);
% output: table containing best networks and their characteristics

%% train, validate, test neural networks of input type
function [] = networkCycleAllCryptos(network_type, num_of_cycles, num_of_neurons)
    networkCycle("btc", network_type, num_of_cycles, num_of_neurons);
    networkCycle("eth", network_type, num_of_cycles, num_of_neurons);
    networkCycle("ltc", network_type,  num_of_cycles, num_of_neurons);
    networkCycle("xmr", network_type,  num_of_cycles, num_of_neurons);
    networkCycle("xrp", network_type,  num_of_cycles, num_of_neurons);
end