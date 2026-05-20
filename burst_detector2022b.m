function [starts,ends,nb_starts,nb_ends]=burst_detector2022b(filtered_Signal,Fs,ignore_cycle,std_tr,band,max_cycles_befor_after,min_cycles_tostart,min_cycles,power_damp_ratio_befor_after)

filtered_Signal = hilbert(filtered_Signal); 
Pha=angle(filtered_Signal);                 
Amp=abs(filtered_Signal);
ignore_cycle=ignore_cycle+1;                

%30s window time
window_time=30; 
window_time=floor(window_time*Fs);

M=smooth(Amp,window_time);            
S=(Amp-M').^2;
S=sqrt(smooth(S,window_time)); 
TR=(M+std_tr.*S)';  
Amp_tred=Amp>TR;    

starts=find(Amp_tred(2:end)-Amp_tred(1:end-1)==1)+1;
ends=find(Amp_tred(1:end-1)-Amp_tred(2:end)==1);

    if ~isempty(starts) && ~isempty(ends)
    
        %if there is not a start point, catches where starts would
        %be bigger than ends (could only happen at very beginning):
        if (starts(1)>ends(1))
            starts=starts(2:end);
        end
        
        %start exists but no end:
        starts=starts(1:min(length(starts),length(ends)));
        ends=ends(1:min(length(starts),length(ends)));
        
        % checking for min cycle to start
        inds=zeros(1,length(starts));
        for i =1:length(starts)
            temp_pha=Pha(starts(i):ends(i));
            M=temp_pha(1:end-1).*temp_pha(2:end); 
            N_pi_to_npi=sum(M<0&(M<-8)); 
            N_ZX=sum(M<0&(M>-.1));     
            N_cycle=min(N_pi_to_npi,N_ZX);
            if N_cycle>=min_cycles_tostart 
                inds(i)=1;
            end
        end
        
        %starts and ends when that index is one indicating burst
        starts=starts(logical(inds));
        ends=ends(logical(inds));
        
      
        new_TR=zeros(1,length(starts));
        for i=1:length(starts)
            new_TR(i)=mean(TR(starts(i):ends(i)));
        end
        
        %expanding
        for i =1:length(starts)
            check_start=0;
            check_end=0;
        
            tmp_ZX1=0;
        
            tmp_ZX2=0;
        
            for C=1:max_cycles_befor_after   
                
        
                if check_start<ignore_cycle && starts(i)>floor(Fs/band(1))
                    new_start=starts(i)-floor(Fs/band(1)); 
                    M=Pha(new_start:starts(i)-1).*Pha(new_start+1:starts(i)); 
                    ZX=find(M<=0&(M>-.1));          %ZX is last zero cross
                    if ~isempty(ZX) && Amp(new_start+ZX(end))>power_damp_ratio_befor_after*new_TR(i)
                        starts(i)=new_start+ZX(end)-1;
                        check_start=0;
                        tmp_ZX1=0;
                    elseif ~isempty(ZX) 
                        check_start=check_start+1;
                        temp=starts(i);
                        starts(i)=new_start+ZX(end)-1;
                        tmp_ZX1=tmp_ZX1+temp-starts(i);
                    else
                        check_start=ignore_cycle; 
                    end
                end
       
                if check_end<ignore_cycle && ends(i)+floor(Fs/band(1))<length(Amp)
                    new_end=ends(i)+floor(Fs/band(1));
                    M=Pha(ends(i):new_end-1).*Pha(ends(i)+1:new_end);
                    ZX=find(M<=0&(M>-.1));
        
                    if ~isempty(ZX) && Amp(ends(i)+ZX(end))>power_damp_ratio_befor_after*new_TR(i)
                        ends(i)=ends(i)+ZX(end)+1;
                        check_end=0;
                        tmp_ZX2=0;
                    elseif ~isempty(ZX)
                        check_end=check_end+1;
                        ends(i)=ends(i)+ZX(end)+1;
                        tmp_ZX2=tmp_ZX2+ZX(end)+1;
                    else
                        check_end=ignore_cycle;
                    end
                end
        
        
            end
            
            %
            if check_start~=0
                starts(i)=starts(i)+tmp_ZX1;
            end
            if check_end~=0
                ends(i)=ends(i)-tmp_ZX2;
            end
        end
        
        
        %if 2 bursts overlap, combine these
        check=true;
        while (check)
            for i=1:length(starts)-1
                if (starts(i+1)<ends(i))
                    ends(i)=ends(i+1);
                    starts(i+1)=[];
                    ends(i+1)=[];
        
                    break
                end
        
            end
        
            if i==length(starts)-1
                check=false;
            end
        
        end

        % checking for min cycle to end
        inds=zeros(1,length(starts));
        for i =1:length(starts)
            temp_pha=Pha(starts(i):ends(i));
            M=temp_pha(1:end-1).*temp_pha(2:end);
            N_pi_to_npi=sum(M<0&(M<-8));
            N_ZX=sum(M<0&(M>-.1));
            N_cycle=min(N_pi_to_npi,N_ZX);
            if N_cycle>=min_cycles
                inds(i)=1;
            end
        end
        starts=starts(logical(inds));
        ends=ends(logical(inds));
        
        %define nb starts & ends
        if isempty(starts)
            nb_ends = [];
            nb_starts= [];

        elseif starts(1)==1 
            nb_ends = starts(2:end);   

            if ends(end)==length(S)
                nb_starts=ends(1:end-1); 
            
            else                                          
                nb_starts = ends(1:end);
                nb_ends = [nb_ends length(S)];
            end
        else 
            nb_starts=1;      
            nb_starts=[nb_starts ends];
            
            nb_ends = starts;   

            if ends(end)==length(S)      
                nb_starts=nb_starts(1:end-1);
            else                         %
                nb_ends = [nb_ends length(S)];
            end
        end
    end
end




