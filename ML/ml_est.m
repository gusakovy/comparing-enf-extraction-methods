function [ml_freq_v,SNR_dB_v, h_coeff_m, notify_flag_v] = ...
    ml_est(signal, fmax, fmin, fs, Nh,options)
% ML_EST - Performs maximum-likelihood estimation via maximization of the
% harmonic likelihood projection (hlp) function.
%
% Syntax:  [ml_freq_v,SNR_dB_v, h_coeff_m, notify_flag_v] = ...
%               ml_est(signal, fmax, fmin, fs, Nh,options)
%
% Inputs:
%    signal - Audio signal.
%    fmax - Upper bound on estimated frequency.
%    fmin - Lower bound on estimated frequency.
%    fs - Sampling frequency.
%    Nh - Number of harmonics.
%    options - optimset object with parameters `Display` (on/off),
%       `MaxIter` and `TolX`.
%       Example: optimset('Display','off','MaxIter',30,'TolX',.025e-3);
%
% Outputs:
%    ml_freq_v - ML estimated frequency.
%    SNR_dB_v - Estimated SNR.
%    h_coeff_m - Estimated harmonics coefficients.
%    notify_flag - -1 if maximization hit one of the bounds, 0 otherwise.
%
% Authors: Dima Bykhovsky, Asaf Cohen
% Source: D. Bykhovsky and A. Cohen, "Electrical Network Frequency (ENF) 
%   Maximum-Likelihood Estimation Via a Multitone Harmonic Model," 
%   in IEEE Transactions on Information Forensics and Security, 
%   vol. 8, no. 5, pp. 744-753, May 2013
% Editors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Last revision: 02-07-2024

ml_freq_v = zeros(1, size(signal,2));
SNR_dB_v = zeros(1, size(signal,2));
notify_flag_v = zeros(1, size(signal,2));
h_coeff_m = zeros(1, size(signal,2));

freq_ini = 100;
lambda = 0; % 0.0001, 1e-5
for m = 1:size(signal,2)
    ml_freq = fminbnd(@(freq)-hlp(signal(:,m), Nh, freq, fs) + lambda * ...
        (norm(freq-100-0.4667*(freq_ini-100),2))^2,fmin,fmax,options);

    if (abs(ml_freq - fmin) < options.TolX*2) || ...
            (abs(ml_freq - fmax) < options.TolX*2)
        % ml_freq = NaN;
        SNR_dB = -10;
        h_coeff = NaN(Nh,1);
        notify_flag = -1;
        % warning('ENF:MLE','Converge on a bound');
        freq_ini = 100;
    else        
        freq_ini = ml_freq;
        [~,SNR_dB,h_coeff] = hlp(signal(:,m),  Nh, ml_freq, fs);
        h_coeff(1) = []; % remove DC component
        if Nh > 1
            notify_flag = sum(h_coeff(2:end).^2)/h_coeff(1)^2;
        else
            notify_flag = 0;
        end
    end
    
    ml_freq_v(m) = ml_freq;
    SNR_dB_v(m) = SNR_dB;
    notify_flag_v(m) = notify_flag;
    h_coeff_m(:,m) = h_coeff;    
end
