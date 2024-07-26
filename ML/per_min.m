function [C_freq,notify_flag] = per_min(signal,fmax,fmin,fs,Nh,options)
% PER_MIN - Implements maximization of the function periodogram_h.
%
% Syntax:  [C_freq,notify_flag] = per_min(signal,fmax,fmin,fs,Nh,options)
% 
% Inputs:
%    signal - Signal vector.
%    fmax - Upper bound on estimated frequency.
%    fmin - Lower bound on estimated frequency.
%    fs - sampling frequency.
%    Nh - Number of harmonics.
%    fs - Sampling frequency.
%    options - optimset object with parameters `Display` (on/off),
%       `MaxIter` and `TolX`.
%       Example: optimset('Display','off','MaxIter',30,'TolX',.025e-3);
%
% Outputs:
%    C - Frequency which maximizes the function periodogram_h.
%    notify_flag - -1 if maximization hit one of the bounds, 0 otherwise.
%
% Authors: Dima Bykhovsky, Asaf Cohen
% Source: D. Bykhovsky and A. Cohen, "Electrical Network Frequency (ENF) 
%   Maximum-Likelihood Estimation Via a Multitone Harmonic Model," 
%   in IEEE Transactions on Information Forensics and Security, 
%   vol. 8, no. 5, pp. 744-753, May 2013
% Editors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Last revision: 02-07-2024

C_freq = zeros(1, size(signal,2));
notify_flag = zeros(1, size(signal,2));

for m = 1:size(signal,2)
    C_freq(m) = fminbnd( ...
        @(freq)-periodogram_h(signal(:,m),Nh,freq,fs),fmin,fmax,options);
    
    if (abs(C_freq(m) - fmin) < options.TolX*2) || ...
            (abs(C_freq(m) - fmax) < options.TolX*2)
        C_freq(m) = NaN;
        notify_flag(m) = 1;
        warning('ENF:periodogram','Converge on a bound');
    else
        notify_flag(m) = 0;        
    end
end
