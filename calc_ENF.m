function data = calc_ENF(signal, fs, params, is_measurement)
% calc_ENF - Calculates the ENF signal from downsampled audio signal, 
% according to the method specified in the parameters.
%
% Syntax:  data = calc_ENF(signal, fs, params, is_measurement)
%
% Inputs:
%    signal - Signal vector.
%    fs = Sampling frequency.
%    params - Parameters object.
%    is_measurement - Whether the signal is a measurement signal 
%       (otherwise treated as the reference signal).
%
% Outputs:
%    data - Data objects comprising the enf signal `data.f`, and the time 
%       axis `data.t`.
%
% Authors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Affiliation: Ben Gurion University of the Negev, Be'er-Sheva, Israel
% Last revision: 02-07-2024

if is_measurement
    f_center = params.freq.f_center(1);
    f_range = params.freq.f_range(1);
else
    f_center = params.freq.f_center(2);
    f_range = params.freq.f_range(2);
end

switch params.enf_extraction_method
    case "STFT"

        [s, f, t] = spectrogram(signal, params.spectrogram.window, ...
        params.spectrogram.noverlap, params.spectrogram.nfft, fs,'yaxis');
    
    
        f1 = f_center - f_range/2;
        f2 = f_center + f_range/2;
        
        [~, f1_idx] = min(abs(f - f1));
        [~, f2_idx] = min(abs(f - f2));
        
        s_cut= s(f1_idx:f2_idx, :);
        f_cut = f(f1_idx:f2_idx);
        
        [~, max_idx] = max(abs(s_cut));
        f_max = f_cut(max_idx);
        
        data.t = t;
        data.f = f_max - f_center;
        data.f = data.f/(f_center/50);

    case "ML"

        addpath("ML")
        options = optimset('Display','off','MaxIter',30,'TolX',.025e-3);
        T = 5;
        L = T * fs;
        step = 0.1*L;
        temp_mat = zeros(L,ceil(length(signal)/(step)));
        pointer = 1;
        col = 1;
        while (pointer+L)<=length(signal)
            temp_mat(:,col) = signal(pointer:pointer+L-1);
            col = col + 1;
            pointer = pointer + step;
        end
        temp_mat = temp_mat(:,1:col-1);
        [ml_freq_v,~, ~, ~] = ml_est(temp_mat, f_center+f_range/2, ...
            f_center-f_range/2, fs, 1,options);
        data.f = ml_freq_v - f_center;
        data.t = linspace(T/2, length(signal)/fs - T/2, length(ml_freq_v));
        data.t = data.t;

    case {"BT", "ESPRIT", "CAPON"}

        addpath("BT_CAPON_ESPRIT")
        [data.f, data.t] = extract_ENF(signal, f_center+f_range/2, ...
            f_center-f_range/2, fs, params.enf_extraction_method);
        data.f = data.f - f_center;

    otherwise

        ME = MException("Unrecognized ENF extraction method %s", ...
            params.enf_extraction_method);
        throw(ME)
end
end
