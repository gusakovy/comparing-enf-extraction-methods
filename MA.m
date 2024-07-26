function [output] = MA(input, window_length)
% MA - Computes the average value of a set of samples within a window
% (Moving Average).
%
% Syntax:  output = MA(input, window_length)
%
% Inputs:
%    input - Signal to apply the moving averagge to.
%    window_length - Amount of samples to include in the average.
%
% Outputs:
%    output - Averaged signal.
%
% Authors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Affiliation: Ben Gurion University of the Negev, Be'er-Sheva, Israel
% Last revision: 02-07-2024

pulse = ones(1, window_length) / window_length;
output = conv(input, pulse, 'same');
