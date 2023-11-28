function [mean_ifft_tf_stimTomic, mean_ifft_tf_micToStim, tf] = ...
    get_transfer_funct(stim_, mic_, samplingrate, numTrials)
% get_transfer_funct: generates transfer function from auditory stimuli 
%   (input vector in matlab) to microphone recording (volt) and vice versa.
%
% Usage:
%   [mean_ifft_tf_stimTomic, mean_ifft_tf_micToStim] = ...
%       get_transfer_funct(stim_, mic_, samplingrate, numTrials)
%
% Args:
%   stim_: auditory input 
%   mic_: microphone recording
%   samplingrate: sampling rate of recordings
%       (assumes they are the samefor both stim_ and mic_)
%   numTrials: max number of trials to load

% default settings
% 2^nextpow2(size(voltageScaled,2));
tf.NFFT = 10000;
tf.NFFTTF = 10000;

% window for pwelch
tf.windowPW = 1000;
tf.noOverlapPW = tf.windowPW/2;

% window for tfestimate
tf.windowTF = 5000;
tf.noOverlapTF = tf.windowTF/2;

for trial = 1:numTrials
   
   % Calculate transfer function between the original stimulus
   % and the microphone output using tfestimate (matlab built-in function)
   tf_stimTomic(trial, :) = tfestimate(stim_(trial, :), ...
       mic_(trial, :), tf.windowTF, tf.noOverlapTF, tf.NFFTTF, samplingrate, 'twoside');
   
   tf_micToStim(trial, :) = tfestimate(mic_(trial, :), ...
       stim_(trial, :), tf.windowTF, tf.noOverlapTF, tf.NFFTTF, samplingrate, 'twoside');   
   
   % calculate the ifft to transformeach TF to frequency domain
   ifft_tf_stimTomic(trial, :) = ifft(tf_stimTomic(trial, :), tf.NFFTTF);
   ifft_tf_micToStim(trial, :) = ifft(tf_micToStim(trial, :), tf.NFFTTF);
   
   disp(['Trial ',num2str(trial),' done (transfer function,...).'])
   
end

mean_ifft_tf_stimTomic = circshift(...
    mean(ifft_tf_stimTomic, 1), [0 tf.NFFTTF/2]);
mean_ifft_tf_micToStim = circshift(...
    mean(ifft_tf_micToStim, 1), [0 tf.NFFTTF/2]);

end
