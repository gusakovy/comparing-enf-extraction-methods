function [harmE,SNR_dB,a] = hlp(s,  Nh, freq, Fs)
% HLP - Implements the harmonic likelihood projection
% without maximization.
%
% Syntax:  [harmE,SNR_dB,a] = hlp(s,  Nh, freq, Fs)
% 
% Inputs:
%   s - Signal vector.
%   Nh - Number of harmonics.
%   freq - Vector of frequencies.
%   Fs - Sampling frequency.
%
% Outputs:
%   harmE - Energy of the harmonic projection.
%   SNR_dB - Estimated SNR.
%   a - Harmonic coefficients (a(1) - dc) .
%
% Authors: Dima Bykhovsky, Asaf Cohen
% Source: D. Bykhovsky and A. Cohen, "Electrical Network Frequency (ENF) 
%   Maximum-Likelihood Estimation Via a Multitone Harmonic Model," 
%   in IEEE Transactions on Information Forensics and Security, 
%   vol. 8, no. 5, pp. 744-753, May 2013
% Editors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Last revision: 02-07-2024

frame_len = length(s);
c=2*pi*((0:frame_len-1)' * (1:Nh));

for k = 1:length(freq)
    freqCur = freq(k);
    A=[ones(frame_len,1)   cos(c*freqCur/Fs)   sin(c*freqCur/Fs)];
    [U,D,~] = svd(A'*A);
    DD = diag(1./sqrt(diag(D)));  
    b = ((U*DD*U')*A')*s;
    harmE(k,:) = sum(b.^2);
    SNR_dB(k,:) = 10*log10(harmE(k,:)./(sum(s.^2) - harmE(k,:)));
	
    a(1,:) = b(1,:);
    a(2:(size(b,1)/2+.5),:) = sqrt(b(2:size(b,1)/2+.5,:).^2 + ...
        b(size(b,1)/2+1.5:size(b,1),:).^2);
end
