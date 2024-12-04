function [nm,  lags] = NM(meas, ref)
% NM - Computes the normalized missalignment between a measurement signal 
%   and a reference signal.
%
% Syntax:  [nm, lags] = NM(meas, ref)
%
% Inputs:
%    meas - Measurement signal.
%    regerence - Reference Signal.
%
% Outputs:
%    nm - The normalized missalignment between the measurement and
%       reference signals.
%    lags - Array of lags between the signals, corresponding to the nm
%       values computed.
%
% Authors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Affiliation: Ben Gurion University of the Negev, Be'er-Sheva, Israel
% Last revision: 02-07-2024

length_diff = length(ref) - length(meas);

nm = zeros(1, length_diff);
lags = 0:length_diff;

for i = 1:(length_diff + 1)
    ref_window = ref(i:(i + length(meas) - 1));
    nm(i) = sum(abs((meas - ref_window).^2)) / sum(abs(ref_window).^2);
end
