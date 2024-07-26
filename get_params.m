function params = get_params()
% GET_PARAMS - Defines the parameters for ENF signal extraction and 
% correlation computation.
%
% Syntax:  params = get_params()
%
% Outputs:
%    params - Object containing all parameters defined herein.
%
% Authors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Affiliation: Ben Gurion University of the Negev, Be'er-Sheva, Israel
% Last revision: 02-07-2024

% General
params.visualize_spectrograms = false;

% ENF extraction method
params.enf_extraction_method = 'STFT';      % STFT, ML, BT, CAPON, ESPRIT

% Downsampling parameters
params.fs = 400;                            % downsampling frequency

% Spectogram parameters (if STFT is used)
params.spectrogram.nsc      = 2048;         % about 5 seconds
params.spectrogram.nfft     = ...
    params.spectrogram.nsc * 100;           % high frequency resolution
params.spectrogram.window   = hamming(params.spectrogram.nsc);
params.spectrogram.noverlap = ...
    floor(params.spectrogram.nsc * 0.9);    % 90% overlap

% Frequency calculation band [f_center - f_range/2, f_center + f_range/2]
% First entry is for measurement signal and the second is for the reference
% These frequencies should be determined according to the spectrogram 
% visualization
params.freq.f_center = [100, 100];
params.freq.f_range  = [0.6, 0.6];

% SNR calculation params
% (signal: f_center, noise: [f_center - noise_df/2, f_center + noise_df/2])
params.noise_df = 0.7;

% Correlation parameters
params.MA_win_len = 20;
params.use_clean_problematic_areas_flag = 1;
params.clean_problematic_areas_padding = 3;
params.criterion = 'cc';                        % 'cc' or 'nm'

% Time stamping parameters
params.allowed_lag_sec = 15;
