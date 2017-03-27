clc
clear
datestr(now)
lib = lsl_loadlib();
result = {};
while isempty(result)
        result = lsl_resolve_byprop(lib,'type','EEG');

end

inlet = lsl_inlet(result{1});
disp('Now receiving data...');
DATA = zeros(16000,5);
i = 1;
        
while  i < 16000
            % get data from the inlet
            [vec,ts] = inlet.pull_sample();
            DATA(i,1:5) = [vec(1:4),ts];
            i = i + 1;
end

EEGDATA = DATA(:,1:4);

% Sampling rate
Fs_ecg = 115200;
Fs_eeg = 1600;
interval = 10;

%Patient Baseline HR
HR_baseline = 60;

fileID = fopen('1.txt');
ecgdata = fscanf(fileID, '%i\n');

%%
%%ECG Data Processing
%Break up by monitoring interval and compute HR in each

%interval
interval_index = 1;
time = (1:length(ecgdata))*(1/Fs_ecg);
for i = 1:interval*Fs_ecg:length(ecgdata)
    interval_first = i;
    interval_last = i+interval*Fs_ecg-1;
    if (interval_last <= length(ecgdata))
        interval_data = ecgdata(i:i+interval*Fs_ecg-1);
    else
        interval_last = length(ecgdata);
        interval_data = ecgdata(i:end);
    end
    time_intervals(interval_index) = time(interval_last);
    %Compute number of heart beats in this interval
    ecgnext = interval_data(2:end);
    ecgnext = [ecgnext; 0];
    beats = find(ecgnext > 3 & interval_data <= 3);
    numBeats = length(beats);
    %Compute Average HR for this interval
    HR_intervals(interval_index) = (numBeats/interval)*60;
    interval_index = interval_index+1;
end
HRvalue = mean(HR_intervals);
%Compute HR Rate of Change across intervals
HRRoC_intervals = (HR_intervals(2:end)-HR_intervals(1:end-1))/interval;
HRRoC_intervals = [0 HRRoC_intervals];
%Displayed value represents average Rate of Change across the entire time
%period
HRRoCvalue = mean(HRRoC_intervals);

%Calculate HR Variability
NNIntervals = [];
NNindex = 1;
PCvalue = 0;
[RRpks RRlocs] = findpeaks(ecgdata, 'MinPeakHeight', 3);
[allpks alllocs] = findpeaks(ecgdata, 'MinPeakHeight', 2.5);
alllocsnext = alllocs(2:end);
alllocsnext = [alllocsnext; 0];
majorlocs = alllocs(find(abs(alllocs-alllocsnext) > 10));
nextRRindex = find(majorlocs == RRlocs(1));
for i = 1:length(RRlocs)-1
    nextRRindex = nextRRindex + 3;
    if majorlocs(nextRRindex) == RRlocs(i+1)
        NNIntervals(NNindex) = RRlocs(i+1)-RRlocs(i);
        NNindex = NNindex + 1;
    else
        PCvalue = PCvalue+1;
        nextRRindex = find(majorlocs == RRlocs(i+1));
    end
end
SDNNvalue = std(NNIntervals);    

%Compute Stress Index
SI_intervals = ((HR_intervals/HR_baseline).*1.1.^HRRoC_intervals*1.05.^PCvalue)/SDNNvalue;
SIcardvalue = mean(SI_intervals)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EEG
%fft
ffteegdata = fft(EEGDATA);
eegdata = ffteegdata;
datapoints = size(eegdata);
prefrontal = eegdata;
time = DATA(:,5);
%Sum signals in the prefrontal region
prefrontalsum = sum(prefrontal);
%Break up by monitoring interval and compute beta frequency power in each
%interval
beta_range = [13 30];
interval_index = 1;
time_intervals = [];
for i = 1:interval*Fs_eeg:length(prefrontalsum)
    interval_first = i;
    interval_last = i+interval*Fs_eeg-1;
    if (interval_last <= length(prefrontalsum))
        interval_data = prefrontalsum(i:i+interval*Fs_eeg-1);
    else
        interval_last = length(prefrontalsum);
        interval_data = prefrontalsum(i:end);
    end
    time_intervals(interval_index) = time(interval_last);
    %Compute Average Power in Beta Frequency range (for this interval)
    BfP_intervals(interval_index) = bandpower(interval_data, Fs_eeg, beta_range);
    %Compute Average Power across all frequencies (for this interval)
    TfP_intervals(interval_index) = bandpower(interval_data);
    interval_index = interval_index+1;
end

%Rate of change calculations
BfPRoC_intervals = (BfP_intervals(2:end)-BfP_intervals(1:end-1))/interval;
BfPRoC_intervals = [0 BfPRoC_intervals];
%Displayed value represents average Rate of Change across the entire time
%period
BfPRoCvalue = mean(BfPRoC_intervals);

%Stress Index Calculations
cogSI_intervals = (BfP_intervals./TfP_intervals) .* 1.1 .^(BfPRoC_intervals);
%Displayed value is average stress index
cogSIvalue = mean(cogSI_intervals)
