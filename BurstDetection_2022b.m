%% Burst detector

function BurstDetection_2022b(ch_idx,recording,data_dir,score_dir, score_file, out_dir_Burst,log);


%Load edf and format channels
echo(data_dir,recording)
EEG_Burst = pop_biosig([data_dir recording '.edf']);
EEG_Burst_Channel = {EEG_Burst.chanlocs.labels};
EEG_Burst_Channel = EEG_Burst_Channel(ch_idx);
EEG_raw_channels = EEG_Burst_Channel';
EEG_Burst.event=[];

clear marks %clear any previously loaded scores
marks = readtable([score_dir score_file '.txt']);
stages = table2array(marks(:,1));        
freq = EEG_Burst.srate;
epoch_size = 30;

% build epochs
indexes = 1:size(stages);
indexes = indexes.';
ends = indexes*epoch_size*freq;
starts = ends-(epoch_size*freq-1);
epoch_details = horzcat(starts,ends,stages);


%%%% BURST DETECTION
%THETA
burst_band=[4 8];
band_name = 'theta';
out_burst_file = burst_detector_wrapper2022b(ch_idx,EEG_Burst_Channel,recording,EEG_Burst,stages,burst_band,band_name,out_dir_Burst,EEG_raw_channels,log); 
upper_dur = 3; %3 second upper cutoff for theta
dur_file = burst_duration_generator2022b(freq,upper_dur,epoch_details,EEG_Burst_Channel,length(EEG_Burst_Channel),out_burst_file,out_dir_Burst);  %3 is the upper second limit for theta bursts
%delete old non-duration file:
delete([out_dir_Burst out_burst_file]);

%ALPHA
burst_band=[8 13];
band_name = 'alpha';
out_burst_file = burst_detector_wrapper2022b(ch_idx,EEG_Burst_Channel,recording,EEG_Burst,stages,burst_band,band_name,out_dir_Burst,EEG_raw_channels,log); 
upper_dur = 2; %2 second upper cutoff for alpha
dur_file = burst_duration_generator2022b(freq,upper_dur,epoch_details,EEG_Burst_Channel,length(EEG_Burst_Channel),out_burst_file,out_dir_Burst);  %3 is the upper second limit for theta bursts
%delete old non-duration file:
delete([out_dir_Burst out_burst_file]);

end