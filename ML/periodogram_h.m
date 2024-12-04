function C = periodogram_h(signal, Nh, freqs, fs)
% PERIODOGRAM_H - Computes the sum of periodograms of the measurements at 
% frequencies w*m where m = 1,...,Nh.
%
% Syntax:  C = periodogram_h(signal, Nh, freqs, fs)
%
% Inputs:
%    signal - Measurement signal.
%    Nh - Number of harmonics.
%    freqs - Vector of frequencies.
%    fs - Sampling frequency.
%
% Outputs:
%    C - Sum of periodograms of the measurement signal at frequencies w*m
%       for m=1,...,Nh.
%
% Authors: Dima Bykhovsky, Asaf Cohen
% Source: D. Bykhovsky and A. Cohen, "Electrical Network Frequency (ENF) 
%   Maximum-Likelihood Estimation Via a Multitone Harmonic Model," 
%   in IEEE Transactions on Information Forensics and Security, 
%   vol. 8, no. 5, pp. 744-753, May 2013
% Editors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Last revision: 02-07-2024

signal = reshape(signal,1,length(signal));
I = zeros(1,length(freqs));
rn = xcorr(signal);

parfor k = 1:length(freqs)    
    w = 2*pi*freqs(k)/fs;
    for m = 1:Nh
        I(k) = I(k) + ...
            real(rn*exp(-1i*(-length(signal)+1:length(signal)-1)*w*m)');
    end
end
C = I;
end
