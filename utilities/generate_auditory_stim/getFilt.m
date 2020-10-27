function oFilter = getFilt(F1, F2, Fs)
% ff: function that generates filters
%
% Usage:
%   ff = getFilt(F1, F2, Fs)
%
% Args:
%   F1: lower cutoff
%   F2: upper cutoff
%   FS: Sampling Frequency

N      = 500;  % Order
Wstop1 = 1;    % First Stopband Weight
Wpass  = 1;    % Passband Weight
Wstop2 = 1;    % Second Stopband Weight

% Calculate the coefficients using the FIRLS function
b  = firls(N, [0 F1 F1 F2 F2 Fs/2]/(Fs/2), [0 0 1 1 0 ...
   0], [Wstop1 Wpass Wstop2]);
oFilter = dfilt.dffir(b);

end
