% Example of how to generate pulse stimuli
% 1) define pulse(train) parameters
% 2) generate single pulse "pulse"
% 3) generate the full pulse train
% 4) save pulse parameters
% 5) save pulse train and parameters
% 6) display: plot pulse+pause and pulse train

% 1) define pulse(train) parameters
% Notes:
% IPI = pulseDuration+pulsePaus (default 36ms)
% standard is 16ms duration and 20ms pause

Fs = 10000;         % sampling rate
pulseDuration = 16; % ms, duration of the pulse
pulsePause = 20;    % ms, pause between pulses
trainDuration = 4;  % seconds
pulseCarrier = 150; % Hz, pulse carrier frequency

% 2) generate single pulse "pulse"
T = (1:pulseDuration*Fs/1000)'/Fs;
% sinusoid with pulse duration and pulse carrier frequency
car = sin(2*pi*T*pulseCarrier + pi/4);
% envelope generating the pulse amplitude profile
env = gausswin(pulseDuration*Fs/1000, 3.5);
% single pulse is the product of the Gaussian envelope and sinusoidal carrier
pulse = env.*car;

% 3) generate the full pulse train
pulseSingle = [pulse; zeros(pulsePause*Fs/1000,1)]; % append pulse pause to pulse
pulseTrain = repmat(pulseSingle, ...
    trainDuration*ceil(Fs/length(pulseSingle)),1); % concatenate multiple pulses

% 4) save pulse parameters
% Notes: for the playback software we need a 1xT vector called 'stim'
pulseParam.pulseDuration = pulseDuration;
pulseParam.pulsePause = pulsePause;
pulseParam.pulseCarrier = pulseCarrier;
pulseParam.trainDuration = trainDuration;
stim = pulseTrain;

% 5) save pulse train and parameters
fileName = sprintf('pulseTrain_PDUR%dms_PPAU%dms_PCAR%dHz_TDUR%ds', ...
    pulseDuration, pulsePause, pulseCarrier, trainDuration);
fprintf('saving pulse train to:\n   %s.mat\n', fileName)
save(fileName, 'stim', 'pulseParam');

%% Display stimuli generated
% 6) display: plot pulse+pause and pulse train
subplot(length(pulsePause), 4, 1)
plot((1:length(pulseSingle))/Fs*1000, pulseSingle, 'k', 'LineWidth', 2)
xlabel('time [ms]')
ylabel('voltage')
title({'single pulse' 'including pause'})

subplot(length(pulsePause), 4, 2:4)
plot((1:length(pulseTrain))/Fs*1000, pulseTrain, 'k', 'LineWidth', 2)
xlabel('time [ms]')
ylabel('voltage')
title('full pulse train')
