% Sampling rate
Fs_ecg = 2538;
Fs_eeg = 250;
interval = 10;

%Patient Baseline HR
HR_baseline = 60;

fileID = fopen('ecgdata.txt');
eee = fscanf(fileID, '%i\n');
ecgdata = eee(1:318000);

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
    beats = find(ecgnext > 800 & interval_data <= 800);
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
[RRpks, RRlocs] = findpeaks(ecgdata, 'MinPeakHeight', 800);
[allpks, alllocs] = findpeaks(ecgdata, 'MinPeakHeight', 550);
alllocsnext = alllocs(2:end);
alllocsnext = [alllocsnext; 0];
majorlocs = alllocs(find(abs(alllocs-alllocsnext) > 10));
nextRRindex = find(majorlocs == RRlocs(1));
for i = 1:length(RRlocs) - 1
    nextRRindex = nextRRindex + 3;
    if majorlocs(nextRRindex) == RRlocs(i+1)
        NNIntervals(NNindex) = RRlocs(i+1)-RRlocs(i);
        NNindex = NNindex + 1;
    else
        PCvalue = PCvalue + 1;
        nextRRindex = find(majorlocs == RRlocs(i+1));
    end
end
SDNNvalue = std(NNIntervals);    

%Compute Stress Index
SI_intervals = ((HR_intervals/HR_baseline).*1.1.^HRRoC_intervals*1.05.^PCvalue)/SDNNvalue;
SIcardvalue = mean(SI_intervals)
