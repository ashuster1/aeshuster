%% This code isolates bursts within REM sleep and within required duration

function out_file_name=burst_duration_generator2022b(fs,upper_dur,epoch_details,EEG_Burst_Channel,ch_num,burst_file_name,out_dir)

rem_indexes = find(epoch_details(:,3)==5);
rem_epochs = epoch_details(rem_indexes,:);


load([out_dir burst_file_name]); %input the output of A_burst_detector_wrapper2022b


if isempty(rem_epochs)
    fprintf('No REM sleep for %s \n',burst_file_name)
else
   
%% start code
    duration_name = [burst_file_name(1:end-4) '_duration.mat'];

    burst_intrv=cell(1,ch_num);
    power=cell(1,ch_num);
    burst_count=[];
    burst_density=[];

    noburst_intrv=cell(1,ch_num);
    noburst_power=cell(1,ch_num);
    noburst_count=[];
    noburst_density=[];
    

    rem_sample=rem_epochs(:,1:2);
    size(rem_sample,1);
    
    a = rem_sample(2:end,1);
    b = rem_sample(1:end-1,2);
    t = find(a-b~=1);
    start_t=cat(1,0,t);
    end_t=cat(1,t,size(rem_sample,1));

    win_t=cat(2,start_t,end_t);
    for i=1:size(win_t,1)
        win_t(i,3) = rem_sample(win_t(i,1)+1,1);
        win_t(i,4) = rem_sample(win_t(i,2),2);
    end
    
    %%

    for ch=1:ch_num
        clear burst_by_ch power_by_ch rem_burst_idx rem_burst_idx_all rem_burst_power_thres
        burst_by_ch=BURSTS{ch};
        power_by_ch=POWER{ch};
        rem_burst_idx=[];
        rem_burst_idx_all = [];

        noburst_by_ch=NOBURSTS{ch};
        noburst_power_by_ch=POWER_NB{ch};
        rem_noburst_idx=[];
        rem_noburst_idx_all = [];
        
        %isolate bursts & non-burst time that are within rem indexes
        for i=1:size(win_t,1)
            %burst
            rem_burst_idx=find(win_t(i,3)<burst_by_ch(:,1) & burst_by_ch(:,1)<win_t(i,4));
            rem_burst_idx_all=cat(1,rem_burst_idx_all,rem_burst_idx);
            %noburst:
            rem_noburst_idx=find(win_t(i,3)<noburst_by_ch(:,1) & noburst_by_ch(:,1)<win_t(i,4));
            rem_noburst_idx_all=cat(1,rem_noburst_idx_all,rem_noburst_idx);
        end
        %burst
        burst_intrv{1,ch}=burst_by_ch(rem_burst_idx_all,:);
        power{1,ch}=power_by_ch(1,rem_burst_idx_all);
        burst_count(1,ch)=length(rem_burst_idx_all);
        burst_density(1,ch)=length(rem_burst_idx_all)/(size(rem_sample,1)*30/60); %REM duration minutes
        %noburst
        noburst_intrv{1,ch}=noburst_by_ch(rem_noburst_idx_all,:);
        noburst_power{1,ch}=noburst_power_by_ch(1,rem_noburst_idx_all);
        noburst_count(1,ch)=length(rem_noburst_idx_all);
        noburst_density(1,ch)=length(rem_noburst_idx_all)/(size(rem_sample,1)*30/60); %REM duration minutes
   
    end


    %define new variables for .5 - 3 second limit for bursts
    %do not do this for non-bursts; this is a slight limitation as we will
    %have some 'burst activity' that is under .5 seconds that is excluded and that is not
    %included in the non-burst metrics
    rem_burst_intrv_thres=burst_intrv;
    rem_burst_count_thres=double(burst_count);
    rem_burst_density_thres=burst_density;
    rem_burst_power_thres=power;


    %old: replace <0.5 and >3 secs (768 = 256fs*3seconds) with duration NaN
    %UPDATED: replace any bursts that are <.05 and > upper_dur threshold with NaN

    %convert upper_dur from seconds to account for sampling frequency
    upper_thres = upper_dur * fs;
    for i=1:ch
        if length(rem_burst_intrv_thres{i})==1 && isnan(rem_burst_intrv_thres{i}(1))
            rem_burst_intrv_thres{i}=[];
        end
        if isempty(burst_intrv{i})
            rem_burst_intrv_thres{i}(:,1)=NaN;
        end
        for j = 1:size(burst_intrv{i},1)
            %thresholds for duration
            if burst_intrv{i}(j,2) - burst_intrv{i}(j,1) <= (.5*fs) || burst_intrv{i}(j,2) - burst_intrv{i}(j,1)>=upper_thres
                rem_burst_intrv_thres{i}(j,:) = NaN;
                rem_burst_count_thres(i) = rem_burst_count_thres(i)-1;
            end

        end
    end

    %correct the count acccording to the threshold above
    for i=1:ch
        rem_burst_count_thres(i) = burst_count(i)-sum(isnan(rem_burst_intrv_thres{i}(:,1)));
    end

    %correct the density acccording to the threshold above
    duration = double(burst_count(1))/burst_density(1);
    rem_burst_density_thres = rem_burst_count_thres/duration;

    %correct the POWER acccording to the threshold above
    for i=1:ch
        idx=isnan(rem_burst_intrv_thres{i}(:,1));
        rem_burst_power_thres{i}(idx)= NaN;
    end

    %save new duration-thresholded channel
    out_file_name = append(duration_name(1:end-4),'.mat');
    save([out_dir out_file_name],'rem_burst_power_thres','rem_burst_density_thres','rem_burst_count_thres','rem_burst_intrv_thres', ...
        'noburst_intrv','noburst_count','noburst_density','noburst_power','EEG_Burst_Channel','marker_file');

end
