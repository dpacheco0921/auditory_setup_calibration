%% calculate the transfer function from DAQ output to sound from the tubing

% 1) White noise stimuli were generate using:
% Notes: white noise: broad band stimulus (80Hz-10^3Hz)
edit make_whitenoise

% 2) Using makeWN generate 'n' WN stimulus and play them 'm' times
%   we have tried n = 5, and m = 10, so total 50 trials across 5 different
%   WN stimuli

% 3) load, filter and normalize amplitude of both auditory and microphone recording

% directory with all the input files (stimuli delivered and recorded voltage from microphone)
mainPath = pwd;

% filename without the trial index (that contains mat files with audio and voltage info)
% 20190801_1_1 trial 1
% 20190801_1_1 trial 2
% ...
filename_preffix = '20190801_1_';
date = sprintf('%02d', round(clock'));
date = [date(1:8)];

filepath = [mainPath, filesep, filename_preffix];

% stimuli onset in seconds
stimStart = 0;
% start offset in seconds
startCut = 2;
% seconds of stimulus to use
timeTaken = 2;
numTrials = 50;
trial_idx_offset = 0;
% recording sampling rate
samplingrate = 10000;

[stim, resp, resp_cut, stim_cut] = ...
    load_aud_volt(numTrials, trial_idx_offset, ...
    'p.data(1, :)', 'p.data(3, :)', samplingrate, ...
    startCut, timeTaken, stimStart, filepath);

% 5) Calculate transfer function
[mean_ifft_tf_stimTomic, ...
    mean_ifft_tf_micToStim, tf] = ...
    get_transfer_funct(stim_cut, resp_cut, samplingrate, numTrials);

plot_pwelch_per_trial(stim_cut, resp_cut, samplingrate, numTrials, tf)

% 6) save transfer function
save(['cal' date '_transferFunction.mat'], ...
    'mean_ifft_tf_micToStim');

%% Test obtained transfer function

trialToTest = 5;

% 1) voltage from mic filtered by the transfer function from mic to stim should
%   yield back to the original stimulus
voltageCorrected = conv(resp_cut(trialToTest, :), ...
    mean_ifft_tf_micToStim, 'same');

figure('name', ['Example using trial ', num2str(trialToTest), ...
    ': original stimulus and corrected voltage from mic'])
pwelch(voltageCorrected, tf.windowPW, tf.noOverlapPW, tf.NFFT, samplingrate)
hold on
pwelch(stim(trialToTest, :)/max(abs(stim(trialToTest, :))), ...
    tf.windowPW, tf.noOverlapPW, tf.NFFT, samplingrate)

% 2) original stimulus filtered by the transfer function from voltage to
%    stimulus should create a distorted version of the stimulus. This
%   distorted version of the stimulus is distorted back in the tube
%   and thus yield (at the output of the tube) to an undistorted output.
%   ==> Original stim X inverse transfer function -> this input travels through
%   the tube (i.e. is multiplied by the tube transfer function) -> output at
%   the end of tube is undistorded.

% stimulus to be played (corrected input vector in matlab)
stimulusCorrected = conv(stim(trialToTest, :), mean_ifft_tf_micToStim, 'same');

figure('name', 'Corrected stimulus before going through system')
pwelch(stimulusCorrected, tf.windowPW, tf.noOverlapPW, tf.NFFT, samplingrate)
title('This should be played...')
hold on

% 3) Multiplying stimulusCorrected by the transfer function from stimulus
%   to voltage (=tube) should yield to a flat voltage (this needs to be
%   tested on the setup by playing the corrected stimulus after recording the
%   output using the microphone!!!)

test = conv(stimulusCorrected, mean_ifft_tf_stimTomic, 'same');
figure('name', 'Corrected stimulus after going through system (expected)')
pwelch(test, tf.windowPW, tf.noOverlapPW, tf.NFFT, samplingrate)

% 4) Compare this to a recorded 'stimulusCorrected' they should be very
%   similar
