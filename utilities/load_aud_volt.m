function [stim, resp, resp_cut, stim_cut] = ...
    load_aud_volt(numTrials, trial_idx_offset, ...
    audstim_var2load, audmic_var2load, samplingrate, ...
    startCut, timeTaken, stimStart, filepath)
% load_aud_volt: loads both copy of delivered auditory stimuli 
%   (input vector in matlab) and microphone recording (volt)
%   it then filters microphone recording to remove low frequencies and 
%   normalize amplitude of both auditory and microphone recording  
%
% Usage:
%   [stim, resp, resp_cut, stim_cut] = ...
%       load_aud_volt(numTrials, trial_idx_offset, ...
%       audstim_var2load, audmic_var2load, samplingrate, ...
%       startCut, timeTaken, stimStart, filepath)
%
% Args:
%   numTrials: max number of trials to load
%   trial_idx_offset: offset to start counting trials 
%   audstim_var2load: string with auditory input variable name and index
%   audmic_var2load: string with microphone recording variable name and index
%   samplingrate: sampling rate of recordings (assumes they are the same)
%   startCut: start offset in seconds
%   timeTaken: seconds of stimulus to use
%   stimStart: stimuli onset in seconds
%   filepath: directory + input file's suffix
%
% Notes:

if ~exist('audstim_var2load', 'var')
    audstim_var2load = 'p.data(1, :)';
end

if ~exist('audmic_var2load', 'var')
    audmic_var2load = 'p.data(3, :)';
end

if ~exist('stimStart', 'var')
    stimStart = 0;
end

for trial_i = 1:numTrials

   load([filepath, num2str(trial_idx_offset + trial_i), '.mat']);
   
   % collect stimulus and recording vectors
   eval('stim(trial_i, :) = ', audstim_var2load, ';')
   eval('resp(trial_i, :) = ', audmic_var2load, ';')
   
   % select a window of points to use (defined by )
   cutIdx = (stimStart + startCut)*samplingrate + (1:timeTaken*samplingrate);
   
   resp_cut(trial_i,:) = resp(trial_i, cutIdx);
   stim_cut(trial_i,:) = stim(trial_i, cutIdx);

   % highpass filter to revome low frequency noise in microphone recording
   % butterworth, 1st order, cutoff of 10 Hz(divide by spr/2 to used
   % frequencies in Hz and not normalized frequencies (see help)
   [b, a] = butter(8, 80/(samplingrate/2), 'high');
   hpf = filtfilt(b, a, resp_cut(trial_i,:));
   
   % multiply by -1 because the phase got reversed (maybe by the filter?)
   resp_cut(trial_i,:) = -1*hpf;
      
   % normalize amp of both stim and rec 
   maxV = max(abs(resp_cut(trial_i,:)));
   resp_cut(trial_i,:) = resp_cut(trial_i,:)/maxV;
   
   maxS = max(abs(stim_cut(trial_i,:)));
   stim_cut(trial_i,:) = stim_cut(trial_i,:)/maxS;
   
   disp(['Trial ', num2str(trial_i), ...
       ' done (loading, signal transformation...).'])
   
end

end
