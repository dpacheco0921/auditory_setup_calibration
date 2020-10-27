%% Generate white noise stimuli
% 1) define bandpass filter
% 2) generate white noise
% 3) save white noise
% 4) display white noise

% 1) define bandpass filter
Fs = 10000;  % Sampling Frequency
F1 = 80;     % lower cutoff
F2 = 1000;   % upper cutoff
T = 4.5;     % duration of noise stimulus (s)

ff = getFilt(F1, F2, Fs);

% 2) generate white noise
Y = rand(1, T*Fs); % white noise signal
stim = filter(ff, Y); % band-pass filtered white noise

% 3) save white noise
stim = stim';

fileName = sprintf('whiteNoise_%d_%dPCAR_%dTDUR', F1, F2, round(T));
fprintf('saving pulse train to:\n   %s.mat\n', fileName)
save(fileName, 'stim');

% 4) display white noise
figure()
subplot(211)
plot(stim)

% band pass filtering produces transients at stim onset - ignore or cut off
subplot(212)
plot(stim(1:1000))
