function plot_pwelch_per_trial(stim_, mic_, ...
    samplingrate, numTrials, tf)
% plot_pwelch_per_trial: plot power spectrum of input and recorded
%   auditory stimulus
%
% Usage:
%   plot_pwelch_per_trial(stim_, mic_, ...
%       samplingrate, numTrials, tf)
%
% Args:
%   stim_: auditory input 
%   mic_: microphone recording
%   samplingrate: sampling rate of recordings (assumes they are the same)
%   numTrials: max number of trials to load
%   tf: transfer function settings

figAll = figure('name', ...
    'All trials plotted, input stimulus and recorded mic');
hold on

for trial = 1:numTrials
   
   % plot stim and voltage
   figure(figAll)
   
   [psd_stim, fStim] = pwelch(stim_(trial,:), ...
       tf.windowPW, tf.noOverlapPW, tf.NFFT, samplingrate);
   phs = plot(fStim, 10*log10(psd_stim), 'b-');
   set(phs, 'tag', num2str(trial))
   
   [psd_mic, fVolt] = pwelch(mic_(trial,:), ...
    tf.windowPW, tf.noOverlapPW, tf.NFFT, samplingrate);

   % divide by frequency if velocity mic used
   % psd_mic = psd_mic./([1:length(fVolt)]');
   
   phv = plot(fVolt, 10*log10(psd_mic), 'k-');
   set(phv, 'tag', num2str(trial))
   
   disp(['Trial ',num2str(trial), ...
       ' done (transfer function,...).'])

end

legend([phs, phv], {'stim', 'resp'})

end
