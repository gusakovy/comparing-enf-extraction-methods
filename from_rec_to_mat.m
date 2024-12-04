function output_path = from_rec_to_mat(file_path, fs)
% FROM_REC_TO_MAT - Reads audio data from a file, downsamples it and saves 
% into as .mat file.
%
% Syntax:  from_rec_to_mat(folder_path, split_flag, output_len)
%
% Inputs:
%    folder_path - Path to a file containing audio data.
%    fs - Sampling frequency.
%
% Outputs:
%    output_path - Path to the created .mat file. The created file
%       comprises [x, fs, fs_orig] where `x` is the downsampled
%       signal, `fs` is the sampling frequency and `fs_orig` is the 
%       original sampling frequency.
%
% Authors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
% Affiliation: Ben Gurion University of the Negev, Be'er-Sheva, Israel
% Last revision: 02-07-2024

[x, fs_orig] = audioread(file_path);

x = x(:, 1);
first_non_zero = find(x~=0, 1, "first");
last_non_zero  = find(x~=0, 1, "last");
x = x(first_non_zero: last_non_zero);
x = resample(x, fs, fs_orig);

output_path = extractBefore(file_path, '.') + ".mat";
save(output_path,'x','fs','fs_orig')
