function [c,lags,f_ref,f_meas] = calc_corr(f_meas, f_ref, params)
% CALC_CORR - Computes the correlation between a measurement signal 
% and a reference signal, using the criterion specified in the parameters.
%
% Syntax:  [c,lags,f_ref,f_meas] = calc_corr(f_ref, f_meas, params)
%
% Inputs:
%    f_meas - Measurement signal.
%    f_ref - Reference signal.
%    params - Parameters object.
%
% Outputs:
%    c - Correlation sequence (according to the criterion used).
%    lags - Array of lags between the signals, corresponding to the
%       correlation values computed.
%    f_ref - Proccessed reference signal.
%    f_meas - Processed measurement signal.
%
% Authors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Affiliation: Ben Gurion University of the Negev, Be'er-Sheva, Israel
% Last revision: 02-07-2024

f_ref_ma = MA(f_ref, params.MA_win_len);
f_meas_ma = MA(f_meas, params.MA_win_len);

if params.use_clean_problematic_areas_flag % Replace spikes w/ MA sequence
    f_ref = clean_problematic_areas(f_ref, f_ref_ma, 0);
    f_meas = clean_problematic_areas(f_meas, f_meas_ma, 0);
else  % Moving Average smoothing
    f_ref  = f_ref_ma;
    f_meas = f_meas_ma;
end

% Moving Average smoothing
f_ref  = MA(f_ref, params.MA_win_len);
f_meas = MA(f_meas, params.MA_win_len);

% Compute correlation according to criterion
switch params.criterion
    case 'cc' % Use normalized correlations as a criterion:
        c = normxcorr2(f_meas, f_ref);
        lags = -(length(f_meas)-1):(length(f_ref)-1);
        rel_idx = find(lags>=0 & lags<=(length(f_ref)-length(f_meas)));
        c = c(rel_idx);
        lags = lags(rel_idx);

    case 'nm' % Use Normalized Missalignment as a criterion:
        [c, lags] = NM(f_meas, f_ref);
        c = -c;
end
