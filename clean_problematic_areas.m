function output = clean_problematic_areas(orig, ma, padd_sample_num)
% CLEAN_PROBLEMATIC_AREAS - Compares the original signal to its MA and
% replaces locations in which the differene in the signal is larger than 3
% times the standard deviation.
%
% Syntax:  output = clean_problematic_areas(orig, ma, padd_sample_num)
%
% Inputs:
%    orig - Original signal.
%    ma - Moving average signal.
%    padd_sample_num - How many samples around an outlier to replace with
%       the ma signal.
%
% Outputs:
%    output - Clean signal.
%
% Authors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Affiliation: Ben Gurion University of the Negev, Be'er-Sheva, Israel
% Last revision: 02-07-2024

output = zeros(size(orig));

for iFreq = 1:size(orig, 2)

    diff_sig = orig(:, iFreq) - ma(:, iFreq);
    diff_std = std(ma(:, iFreq));
    
    loc_above = find(diff_sig > 3*diff_std);
    loc_below = find(diff_sig < -3*diff_std);
    
    loc = union(loc_above,loc_below);
    temp = repmat(loc,1,padd_sample_num*2+1) + ...
        repmat(-padd_sample_num:padd_sample_num, length(loc),1);
    loc_padded = unique(temp(:));
    
    loc_padded = loc_padded(loc_padded>0);
    loc_padded = loc_padded(loc_padded<=length(orig(:, iFreq)));
    
    output(:, iFreq) = orig(:, iFreq);
    output(loc_padded, iFreq) = ma(loc_padded, iFreq);
end
