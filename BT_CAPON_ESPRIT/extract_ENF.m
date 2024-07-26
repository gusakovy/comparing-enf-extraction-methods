function [ENF_estimation, t] = extract_ENF(signal, fmax, fmin, fs, option)
% EXTRACT_ENF - Extracts the ENF signal using one of the following methods:
% Short Time Fourier Transform (STFT), Blackman-Tukey (BT), 
% Estimation by Rotational Invariance Techniques (ESPRIT), or Capon.
%
% Syntax:  [ENF_estimation, t] = ...
%               extract_ENF(signal, fmax, fmin, fs, option)
%
% Inputs:
%    signal - Signal vector.
%    fmax - Upper bound on estimated frequency.
%    fmin - Lower bound on estimated frequency.
%    fs - Sampling frequency.
%    option - Method to use from 'STFT', 'BT', 'ESPRIT', or 'CAPON'.
%
% Outputs:
%    ENF_estimation - Estimated ENF signal.
%    t - Time vector.
%
% Authors: Georgios Karantaidis, Constantine Kotropoulos.
% Source: GG. Karantaidis and C. Kotropoulos, "Assessing spectral 
%   estimation methods for electric network frequency extraction,” 
%   in Proceedings ofthe 22nd Pan-Hellenic Conference on Informatics, 
%   2018, pp. 202–207.
% Editors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Last revision: 02-07-2024

Fs        = fs;                 % sampling frequency (Hz)
F_Nyq     = Fs/2;               % Nyquist frequency (Hz)

F_pass1   = fmin;               % First cut-off frequency (Hz)
F_pass2   = fmax;               % Second cut-off frequency (Hz)
   
F_pass1_n = F_pass1/F_Nyq;      % Normalized frequency
F_pass2_n = F_pass2/F_Nyq;      % Normalized frequency

N         = 1501;               % Filter order (must be odd number)
win       = hamming(N);         % Window function

% Filter coefficients (impulse response)
b         = fir1(N-1,[F_pass1_n F_pass2_n],'bandpass',win,'scale'); 
                                
data_filtered = filtfilt(b,1,signal);

clear b F_Nyq F_pass1 F_pass1_n F_pass2 F_pass2_n N win


%% Variable setup

frame_len_secs_data1 = 5;                    % frame length (seconds)             
signal_len     = length(signal);             % signal length 
frame_length   = frame_len_secs_data1 * Fs;  % frame length in samples

shift_amount   = Fs/2;                       % 1sec * Fs

nfft= 4*frame_length;                        % numbers of fft
  
w1 = rectwin(frame_length);                  % Rectangular window 
w2 = rectwin(frame_length/4); 
data_filtered1=data_filtered(1:signal_len);  % dummy variable


%% Manual STFT

% form the stft matrix

% calculate the total number of rows
rown = ceil((1+nfft)/2);            
% calculate the total number of columns
coln = 1+fix((signal_len-frame_length)/shift_amount);        

% initialize the indexes
indx = 0;
col = 1;

% perform STFT
while indx + frame_length <= signal_len

    % windowing
    xw = data_filtered1(indx+1:indx+frame_length).*w1;

    switch option
        case 'STFT'
            % STFT
            X = fft(xw, nfft);
            type_ind = 1;
        case 'BT'
            % Blackman-Tukey method
            X=btse(xw,w2,nfft);
            type_ind = 1;
        case 'ESPRIT'
            % Music - identical to ESPRIT
            % X =music(xw,2,4);

            % E-sprit
            X = esprit(xw,2,4);
            type_ind = 2;
        case 'CAPON'
            % Capon
            X=capon(xw,50,nfft);
            type_ind = 1;
    end

    if type_ind==1
        stft(:, col) = X(1:rown);
    elseif type_ind==2
        stft(:, col) = X(:,1);
    end
    % update the indexes
    indx = indx + shift_amount;
    col = col + 1;
end

% calculate the time and frequency vectors
t = (frame_length/2:shift_amount:frame_length/2+(coln-1)*shift_amount)/Fs;
f = (0:rown-1)*Fs/nfft;

% Calculate Power Spectrum
for ii=1:col-1
    Power_Spectrum(:,ii)=(abs(stft(:,ii)).^2)/frame_length;
end

power_vector=log10((Power_Spectrum));       % compute power vector

%% Compute ENF

if type_ind==1
    [~, index] = max(power_vector);         % find indices of max power
    delta = QuadraticInterpolation(power_vector,index,f);
    maxFreqs=f(index);
    ENF_estimation=(maxFreqs+delta);
elseif type_ind==2
    % Mean value for ESPRIT
    FREQS_ESPRIT = stft(:,:).*(Fs/(2*pi));
    FREQS_ESPRIT=abs(FREQS_ESPRIT);
    for jj=1:size(FREQS_ESPRIT,2)
        ENF_estimation(1,jj)=(FREQS_ESPRIT(2,jj));
    end
end
