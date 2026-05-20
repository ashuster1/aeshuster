function out_file=burst_detector_wrapper2022b(ch_idx,EEG_Burst_Channel,recording,EEG_Burst,stages,freq_band,band_name,out_dir_Burst,EEG_raw_channels,log)

marker_file = stages;
rem_idx = find(marker_file==5);

%filter eeg to desired band
EEG = pop_eegfiltnew(EEG_Burst, 'locutoff',freq_band(1),'hicutoff',freq_band(2),'plotfreqz',0);
EEG_ch = {EEG.chanlocs.labels}'; 

BURSTS={};
POWER={};
NOBURSTS={};
POWER_NB={};
 
for ch=1:length(ch_idx)
    POWER{ch}=[];
    NOBURSTPOWER{ch}=[];
  

    if isempty(EEG_ch(ch))
        log{end+1}=sprintf('Empty Channels for %s \n',[data_dir recording]);
    else

        my_ch_idx = ch_idx(ch);
        filtered_data=EEG.data(my_ch_idx,:);
    
        %burst detector
        [starts,ends,NB_starts,NB_ends]=burst_detector2022b(filtered_data,EEG.srate,floor(mean(freq_band)/3),2,freq_band,15,0,ceil(mean(freq_band)/3),.5);
    
        BURSTS{ch}=[starts',ends'];
        for i=1:length(starts)
            POWER{ch}(i)=sum(filtered_data(starts(i):ends(i)).^2)/(ends(i)-starts(i));
    
        end
        
        NOBURSTS{ch}=[NB_starts',NB_ends'];
        for i=1:length(NB_starts)
            POWER_NB{ch}(i)=sum(filtered_data(NB_starts(i):NB_ends(i)).^2)/(NB_ends(i)-NB_starts(i));
        end
    end


end
out_file = append(recording,'_burst_detection','_',band_name,'.mat');

save([out_dir_Burst out_file],'BURSTS','NOBURSTS','EEG_Burst_Channel','POWER','POWER_NB','rem_idx','marker_file')


