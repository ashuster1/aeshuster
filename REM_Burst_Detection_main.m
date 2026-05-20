%% Mednick Lab, UCI REM Burst Code
% This code runs the REM burst detection pipeline for theta and alpha bursts
    % If you just want to run alpha (or just theta), you can easily remove the non-desired band from BurstDetection_2022b.m 
% Needed inputs: EEG file as .edf and score file
% **This code was originally created and run on Matlab 2022b and has not been tested with all later versions 
% Matlab toolboxes installed (not all may be necessary depending on which Matlab version you use): 
    % Bioinformatics
    % Computer Vision
    % Curve Fitting
    % Data Acquisition
    % Signal Processing
    % Statistics and Machine Learning
    % Wavelet
% You will also need these matlab toolboxes saved within your Matlab path:
    % eeglab (version last used with pipeline: 2022.1) and the biosig plugin
    % chronux toolbox (version last used with pipeline: 2_12)
% Burst-relevant outputs
    % The final output is the '..._duration.mat' file.
    % rem_burst_intrv_thres: per channel 2 columns where each row indicates the start (col 1) and end (col 2) of a burst time points in fs
    % rem_burst_power_thres: per channel, 1 column holding the power per burst identified index matched to the rows of rem_burst_intrv_thres 
    % rem_burst_count_thres: number bursts identified per channel
    % rem_burst_density_thres: density of bursts per channel
    % noburst...: equivalent info for non-burst activity
    % EEG_Burst_Channel: channel names
    % marker_file: sleep scores by epoch (col 1 = start epoch, col 2 = end epoch, col 3 = sleep score)
% These outputs do not include any cleaning, it is strongly recommended to thoroughly inspect your data and conduct outlier removal
    % rem_burst_power_thres particularly should be examined to exclude noisy data
    

clc
clear
close all

%% Loading libraries and environment setup

%% 1. Add the path where you saved the REM burst functions
addpath('BurstCodeFilePath')

%% 2. Add your eeglab path
%note: make sure you have the biosig toolbox downloaded and activated within eeglab
addpath('YourPath\eeglab2022.1');
eeglab;


%% 3. Add your chronux path
chronux_dir = 'YourPath\chronux_2_12\spectral_analysis\continuous\'
addpath(chronux_dir);
chronux_dir = 'YourPath\chronux_2_12\chronux_2_12\spectral_analysis\helper\'
addpath(chronux_dir);

%% 4. Define your EEG channel indexes 
%This code is intended for neural channels only
ch_idx = [1,2,3,4,5,6];

%% 5. Define your output directory
out_dir_Burst = 'YourOutputDirectory\'  %include the '\' at the end, this will be needed for file saving later 

%% 6. Load .edf and score file
% This code was set-up to load a .txt score file with one column containing the numeric sleep scores per epoch (no header)
% If your score files follow a different format, you can either 1) reformat your files or 2) update the code

data_dir = 'YourPath\EDF Folder\'; %location of your edf file
recording = 'YourScoreFilename'; %do NOT include the .edf (the code assumes this is .edf later)

score_dir = 'YourPath\Score Folder\'; %location of your score file
score_file = 'YourScoreFilename'; %do NOT include the .txt (the code assumes this is .txt later)


%% 7. Run Burst Detection
log = {};
try
    BurstDetection_2022b(ch_idx,recording,data_dir,score_dir,score_file, out_dir_Burst,log);
catch ME
    log{end+1}=sprintf('Error processing %s \n',recording);
end
    



