%% help 
% trains networks of input type over input number of cycles, with input
% maximum of neurons. calculates profits based on input initial funds and
% maximum risk coefficient
% input: number of cycles to train neural networks
%        maximum number of neurons
%        initial funds
%        maximum risk coefficient
%        network type
% syntax: networksAndProfits(num_of_cycles, num_of_neurons, initial_funds,
% max_risk_coeff, network_type)
% network types: "shallow", "gru", "lstm1", "lstm2"
% e.g.: networksAndProfits(50, 32, 10000, 0.02, "lstm1");
% output: best trained networks and their characteristics, profits for
% trading

%% train, validate, test networks, calculate profits
function [] = networksAndProfits(num_of_cycles, num_of_neurons, initial_funds, max_risk_coeff, network_type)
    networkCycleAllCryptos(network_type, num_of_cycles, num_of_neurons);
    profitAllCryptos(initial_funds, max_risk_coeff, num_of_cycles, num_of_neurons, network_type)
end