% This is the main code of our project. The program does the following:
% 
% 1. Compute and visualize the spectrogram of the audio measurement and 
%    reference signals (so the user can choose a central frequency for ENF
%    extraction).
%
% 2. Extract the ENF using chosen method from the list of available
%    methods.
%
% 3. Compute the correlation using the provided criterion and plot the enf
%    signals aligned, providing the optimal time stamp for the measurement
%    signal within the reference signal.
%
% To change the parameters, edit the file `get_params.m`.
%
% Authors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Affiliation: Ben Gurion University of the Negev, Be'er-Sheva, Israel
% Last revision: 02-07-2024

clc
clear

%% Data Handling

% Unpack parameters
params = get_params();

% File paths - edit this to match your system
meas_path = 'data\meas_sec_150_390.mat';
ref_path = 'data\ref.mat';

if ~endsWith(meas_path, '.mat')
    meas_path = from_rec_to_mat(meas_path, params.fs);
end

if ~endsWith(ref_path, '.mat')
    ref_path = from_rec_to_mat(ref_path, params.fs);
end

load(meas_path, 'x', 'fs')
meas_signal = x;
meas_fs = fs;

load(ref_path, 'x', 'fs')
ref_signal = x;
ref_fs = fs;

clear x fs;

%% Compute and visualize spectrogram
% This visualization is meant to assisnt determining which central 
% frequencies to use for the measurement and reference recordings
% (can be changed in get_params.m).

% Measurement signal spectrogram
if params.visualize_spectrograms
    [s, f, t] = spectrogram(meas_signal, params.spectrogram.window, ...
        params.spectrogram.noverlap, params.spectrogram.nfft, meas_fs, ...
        'yaxis');
    
    figure;
    m1 = 1; m2 = length(f);
    imagesc(t,f(m1:m2),10*log(abs(s(m1:m2, :))))
    xlabel("time [s]")
    ylabel("frequency [Hz]")
    title("Measurement signal spectrogram")
end

% Reference signal spectrogram
if params.visualize_spectrograms
    [s, f, t] = spectrogram(ref_signal, params.spectrogram.window, ...
        params.spectrogram.noverlap, params.spectrogram.nfft, ref_fs, ...
        'yaxis');
    
    figure;
    m1 = 1; m2 = length(f);
    imagesc(t,f(m1:m2),10*log(abs(s(m1:m2, :))))
    xlabel("time [s]")
    ylabel("frequency [Hz]")
    title("Reference signal spectrogram")
end

clear s f;

%% ENF signal extraction

fprintf("ENF Extraction Method: %s\n", params.enf_extraction_method);
fprintf("Correlation Criterion: %s\n", params.criterion);

% Extract ENF
meas_data = calc_ENF(meas_signal, meas_fs, params, true);
ref_data = calc_ENF(ref_signal, ref_fs, params, false);

f_meas = meas_data.f;
f_ref = ref_data.f;
time = ref_data.t;

fprintf("Reference length: %.2f minutes\n", ref_data.t(end)/60);
fprintf("Measurement length: %.2f minuets\n", meas_data.t(end)/60);

%% Correlation and visualization 

[c, lags, f_ref, f_meas] = calc_corr(f_meas, f_ref, params);

T = length(time);
[max_corr, idx_max] = max(c);
lag = lags(idx_max);

fprintf("Maximal correlation according to the %s criterion: %.2f\n", ...
    params.criterion, max_corr);
fprintf("Time stamping result: %.2f seconds\n", time(idx_max))

subplot(1,2,1)
hold on
plot(time(1:length(c)), c)
plot([time(idx_max), time(idx_max)], [0, max_corr], 'r--')
title('Correlation sequence')
xlabel("Time [s]")
ylabel("Correlation")
grid on
hold off

subplot(1, 2, 2)
hold on
plot(time, f_ref - mean(f_ref))
plot(time((lag+1):(lag + length(f_meas))), f_meas - mean(f_meas))
xlabel("Time [s]")
ylabel("Deviation from Central Frequency [Hz]")
title("Aligned ENF signals")
legend('Reference', 'Measurement')
grid on
hold off
