%128 channels
%256 Hz sampling rate
%16 bit analogue-to-digital converter
%% Patient 1

% 		EEG seizure onset (sample)     	EEG seizure end (sample)
% 
% 010403ba_0007 	91100				96090
% 010403ba_0008 	73382				78125
% 010403ba_0013 	82010				83855
% 010403ba_0015 	349009				350891
% 
% ----------
% Electrodes
% ----------
% InFokus1	G_A4
% InFokus2	IH4
% InFokus3	IH3
% OutFokus1	G_D2
% OutFokus2	IHA1
% OutFokus3	IH1

%% Patient 1: DATA SET 7

%LOAD ALL RELEVANT FILES
load 010403ba_0007_1.asc;
load 010403ba_0007_2.asc;
load 010403ba_0007_3.asc;
load 010403ba_0007_4.asc;
load 010403ba_0007_5.asc;
load 010403ba_0007_6.asc;

%TIME VECTORS
freq = 256;
%entire plot
time = linspace(0,921600/freq, 921600);
%time vector of seizure
timeS = linspace(91100/freq, 96090/freq, 96090-91100+1);

%PLOT ALL 6 ELECTRODE CHANNELS 
for i = 1:6
%seizure values
str = eval(['X010403ba_0007_' num2str(i)]);
sData1 =(str(91100:96090,1));
%plot of all
subplot(3, 2, i);
plot(time, str);
xlabel('Time(sec)');
ylabel('Voltage(Hz)');
%plot of just seizure
hold
plot(timeS,sData1, 'r');
title(['Electrode 7.' num2str(i)]);
xlim([0 921600/freq ]);
end


%% TIME SIGNAL ---- DATA SET 7, 8, 13, 15 
sFile = ['010403ba_0007_'; 
        '010403ba_0008_';
        '010403ba_0013_';
        '010403ba_0015_'];
sName = ['X010403ba_0007_'; 
        'X010403ba_0008_';
        'X010403ba_0013_';
        'X010403ba_0015_'];
sLoc = [91100 96090;
        73382 78125;
        82010 83855;
        349009 350891];
    
%USER INPUT  
sect = 3;

%LOAD CORRECT FILES
for i = 1:6
    str = [sFile(sect,:) num2str(i) '.asc'];
    load (str);
end

%VARIABLES
tempName = eval([sName(sect,:) num2str(1)]);
size = length(tempName);
freq = 256;

%CALCULATE 
seizS = sLoc(sect, 1);
seizE = sLoc(sect, 2);

%entire plot
time = linspace(0,size/freq, size);
%time vector of seizure
timeS = linspace(seizS/freq, seizE/freq, seizE-seizS+1);

%PLOT ALL 6 ELECTRODE CHANNELS --- TIME SIGNAL
figure();
for i = 1:6;
%seizure values
str = eval([sName(sect,:) num2str(i)]);
sData1 =(str(seizS:seizE,1));

%insert filters here
fNorm = 50/(freq/2);
[b, a] = butter(5, [49 51]./(freq/2), 'stop');
filtStrT = filtfilt(b, a, str);
filtsData1T = filtfilt(b, a, sData1);

% %low pass butterworth
% fNorm = 60/(freq/2);
% [b, a] = butter(5, fNorm, 'low');
% filtStr = filtfilt(b, a, filtStrT);
% filtsData1 = filtfilt(b, a, filtsData1T);
% 
% %downsample data
% dStr = decimate(filtStr, 2);
% dsData1 = decimate(filtsData1, 2);
% dtime = linspace(0,size/freq, size/2);
% dtimeS = linspace(seizS/freq, seizE/freq, (seizE-seizS)/2);

%plot of all
subplot(3, 2, i);
    plot(time, filtStrT);
    %plot(time, str);
xlabel('Time(sec)');
ylabel('Voltage(Hz)');
%plot of just seizure
hold
    plot(timeS,filtsData1T, 'r');
    %plot(timeS,sData1, 'r');
title(['Time Signal - Electrode' num2str(sect) '.' num2str(i)]);
xlim([0 size/freq ]);
end

%% FREQUENCY SIGNAL
%USER INPUT
sect = 1;
chan = 2; 
%PLOT
figure();
%seizure values
str = eval([sName(sect,:) num2str(chan)]);
sData1 =(str(seizS:seizE,1));
sizeS = length(sData1);

%inset filters here 
%butteworth bandstop
fNorm = 50/(freq/2);
[b, a] = butter(5, [49 51]./(freq/2), 'stop');
filtStrT = filtfilt(b, a, str);
filtsData1T = filtfilt(b, a, sData1);
%low pass butterworth
fNorm = 60/(freq/2);
[b, a] = butter(5, fNorm, 'low');
filtStr = filtfilt(b, a, filtStrT);
filtsData1 = filtfilt(b, a, filtsData1T);

%calculate frequency all signal
freqT = freq*(-(size/2):(size/2))/size;
    %freqStr = fftshift(fft(str));
    freqStr = fftshift(fft(filtStr));
freqStr=[freqStr; freqStr(1)];
%calculate frequency seizure signal
freqST = freq*(-(sizeS/2):(sizeS/2))/sizeS;
    %freqsData1 = fftshift(fft(sData1));
    freqsData1 = fftshift(fft(filtsData1));
freqsData1=[freqsData1; freqsData1(1)];
%freqsData1 = [freqsData; freqsData1(1)];

%plot of magnitude
%subplot(1, 2, 1);
plot(freqT, abs(freqStr));
xlabel('Frequency(Hz)');
ylabel('Magnitude');
hold on
%plot of seizure magnitude
%plot(freqST, abs(freqsData1), 'r');
title(['Filtered Frequency Signal - Electrode' num2str(sect) '.' num2str(chan)]);

% %plot of angle
% subplot(1,2,2);
% plot(freqT, angle(freqStr));
% xlabel('Frequency(Hz)');
% ylabel('Angle');
% hold on
% %plot of seizure angle
% plot(freqST, angle(freqsData1), 'r');
% title(['Frequency Signal - Electrode' num2str(sect) '.' num2str(chan)]);
%% DOWNSAMPLE SIGNALS
%USER INPUT
chann = 2; 
sFile = ['010403ba_0006_';
        '010403ba_0007_'; 
        '010403ba_0008_';
        '010403ba_0012_';
        '010403ba_0013_';
        '010403ba_0014_';
        '010403ba_0015_'];
sName = ['X010403ba_0006_';
        'X010403ba_0007_'; 
        'X010403ba_0008_';
        'X010403ba_0012_';
        'X010403ba_0013_';
        'X010403ba_0014_';
        'X010403ba_0015_'];
%LOAD CORRECT FILES
for i = 1:7
    str = [sFile(i,:) num2str(chann) '.asc'];
    load (str);
end

%finalSig = zeros(size(sFile)*921600,1);
finalSig = [];
for i = 1:7
    
%VARIABLES
size = 921600;
freq = 256;

%CALCULATE 
% seizS = sLoc(i, 1);
% seizE = sLoc(i, 2);

%PLOT ALL 6 ELECTRODE CHANNELS --- TIME SIGNAL
figure();

%seizure values
[sName(i,:) num2str(chann)]
str = eval([sName(i,:) num2str(chann)]);
    %sData1 =(str(seizS:seizE,1));

%insert filters here
[b, a] = butter(5, [49 51]./(freq/2), 'stop');
filtStrT = filtfilt(b, a, str);
    %filtsData1T = filtfilt(b, a, sData1);

%low pass butterworth
fNorm = 60/(freq/2);
[b, a] = butter(5, fNorm, 'low');
filtStr = filtfilt(b, a, filtStrT);
    %filtsData1 = filtfilt(b, a, filtsData1T);

%downsample data
dStr = decimate(filtStr, 2);
length(dStr)
length(finalSig)
finalSig = [finalSig; dStr];
length(finalSig)
    %dsData3 = decimate(filtsData1, 2);
dtime = linspace(0,size/freq, size/2);
    %dtimeS3 = linspace(seizS/freq, seizE/freq, (seizE-seizS)/2+1);
%plot of all
%subplot(2, 2, i);
    plot(dtime, dStr);
    %plot(time, str);
xlabel('Time(sec)');
ylabel('Voltage(Hz)');
    %plot of just seizure
    %hold
    %plot(dtimeS,dsData, 'r');
    %plot(timeS,sData1, 'r');
title(['Time Signal - Electrode' num2str(i) '.' num2str(chann)]);
xlim([0 size/freq ]);
    
end

time = linspace(0, (size/freq)*7, 460800*7);
plot(time, finalSig);
xlim([0 25200]);
xlabel('Time(sec)');
ylabel('Voltage(Hz)');
title(['Total Time Signal - Channel' num2str(chann)]);
%% FIND SEIZURES -------------------
%% Location of seizures
% 		EEG seizure onset (sample)
% 
% 010403ba_0007 	91100 ---- 921600 + 91100 = 1012700
% 010403ba_0008 	73382 ---- 921600*2 + 73382 = 1916582
% 010403ba_0013 	82010 ---- 921600*4 + 82010 = 3768410
% 010403ba_0015 	349009 ---- 921600*6 + 349009 = 5878609

% Seize = zeros(1, 4);
% Seize(1, 1) = 1012700;
% Seize(1, 2) = 1916582;
% Seize(1, 3) = 3768410;
% Seize(1, 4) = 5878609;

Seize = zeros(4, 1);
Seize(1, 1) = 1012700;
Seize(2, 1) = 1916582;
Seize(3, 1) = 3768410;
Seize(4, 1) = 5878609;

% for i = 1:length(Seize)
%     plot([Seize(i)/256 Seize(i)/256], [-3000 4000], 'r');
% end
%% Calculate Energy
energyFinal = (abs(finalSig).^2);
%plot of all
plot(time, energyFinal);
hold on
%plot actual seizure locations
for i = 1:length(Seize)
   plot([Seize(i)/256 Seize(i)/256], [0 300000000], 'k');
end
hold off
xlabel('Time(s)');
ylabel('Voltage(Hz)');
title(['Energy Signal - Channel' num2str(2)]);
legend('Signal', 'Actual Seizure');
xlim([0 25200]);
%% Calculate Line Length
data = finalSig;
frequency = 256/2;
L = 10;
d = 1; 
time = linspace(0, (size/freq)*7, 460800*7);

figure();
    %plot(time, data);
    %hold on
%line length feature with rf = running feature and ni = number ignored from
%left
[rf,ni] = rfeature(data,inline('sum(abs(diff(data)))'),L*frequency,d*frequency);
%scales up the graph/aligns
llFeat = [NaN(1, ni+L*frequency-1) zohinterp(rf(1:end-1), d*frequency) rf(end)];
%normalize
plot(time, llFeat*2*max(data)/max(llFeat), 'g')
xlabel('Time(s)');
ylabel('Voltage(Hz)'); %All (scaled + offset) on EEG
    %legend('Total Signal', 'Line-Length Feature');
    %hold off
hold on
%plot actual seizure locations
for i = 1:length(Seize)
   plot([Seize(i)/256 Seize(i)/256], [0 40000], 'k');
end
hold off
legend('Signal', 'Actual Seizure');
title(['Line Length Signal - Channel' num2str(2)]);
xlim([0 25200]);
%% Find Peaks
%plot(rf)
%hold on
%plot(llFeat*2*max(data)/max(llFeat))
%stores values greater than thresh into new vector
thresh = 9.0*10^5;
rfEdit = zeros(1,length(rf));
rfPeaks = zeros(1, length(rf));
for i = 1:length(rf)
    if (rf(i)>thresh)
        rfEdit(i) = rf(i);
    end
end
%stores all values following zeros into new vector
for i = 1:length(rf)-1
    if(rfEdit(i) == 0)
        rfPeaks(i+1) = rfEdit(i+1);
    end
end
%finds non zero values in vector
Peaks = find(rfPeaks >0);

figure()
hold on
for i = 1:length(Seize)
   plot([Seize(i)/256 Seize(i)/256], [0 50000], 'k');
end
plot(time, llFeat*2*max(data)/max(llFeat), 'b')
for i = 1:length(Peaks)
    plot([Peaks(i) Peaks(i)], [0 40000], 'r');
end
xlabel('Time(s)');
ylabel('Voltage(Hz)');
title('Line Length Seizure Detection');
%legend('Actual Seizure', 'Predicted Seizure', 'Signal');
xlim([0 25200]);
hold off
%% SCRAPS


%% Filter
%low pass butterworth
fNorm = 40/(freq/2);
[b, a] = butter(5, fNorm, 'low');
filtStr = filtfilt(b, a, str);
filtsData1 = filtfilt(b, a, sData1);

%band pass notch filter to remove frequency at 50
% --> don't have correct Matlab toolbox
wo = 50/(freq/2);
bw = fNorm/35;
[b, a] = irrnotch(wo,bw);
fvtool(b,a);

%butteworth bandstop filter @ 50
fNorm = 50/(freq/2);
[b, a] = butter(5, [49 51]./(freq/2), 'stop');
filtStr = filtfilt(b, a, str);
filtsData1 = filtfilt(b, a, sData1);

%% ENERGY SIGNAL
%USER INPUT
sect = 1;
chan = 2; 

%LOAD CORRECT FILES
for i = 1:6
    str = [sFile(sect,:) num2str(i) '.asc'];
    load (str);
end

%VARIABLES
tempName = eval([sName(sect,:) num2str(1)]);
size = length(tempName);
freq = 256;

%CALCULATE 
seizS = sLoc(sect, 1);
seizE = sLoc(sect, 2);

%TIME VECTORS
time = linspace(0,size/freq, size);
%time vector of seizure
timeS = linspace(seizS/freq, seizE/freq, seizE-seizS+1);

%PLOT ENERGY
figure();
%seizure values
str = eval([sName(sect,:) num2str(chan)]);
sData1 =(str(seizS:seizE,1));

%filters
fNorm = 50/(freq/2);
[b, a] = butter(5, [49 51]./(freq/2), 'stop');
filtStr = filtfilt(b, a, str);
filtsData1 = filtfilt(b, a, sData1);

%calculate energy
cumStr = (abs(filtStr).^2);
cumsData1 =(abs(filtsData1).^2);
%plot of all
plot(time, cumStr);
xlabel('Time(sec)');
ylabel('Voltage(Hz)');
%plot of just seizure
hold
plot(timeS,cumsData1, 'r');
title(['Energy Signal - Electrode' num2str(sect) '.' num2str(chan)]);
xlim([0 size/freq ]);

%% PLOT POWER
figure();
%seizure values
str = eval([sName(sect,:) num2str(chan)]);
sData1 =(str(seizS:seizE,1));
%filter
fNorm = 50/(freq/2);
[b, a] = butter(5, [49 51]./(freq/2), 'stop');
filtStr = filtfilt(b, a, str);
filtsData1 = filtfilt(b, a, sData1);

%calculate energy
powStr = ((filtStr).^2)/length(str);
powsData1 = ((filtsData1).^2)/length(str);
%plot of all
plot(time, powStr);
xlabel('Time(sec)');
ylabel('Voltage(Hz)');
%plot of just seizure
hold
plot(timeS,powsData1, 'r');
title(['Power Signal - Electrode' num2str(sect) '.' num2str(chan)]);
xlim([0 size/freq ]);
%% LINE LENGTH
figure();
%seizure values
str = eval([sName(sect,:) num2str(chan)]);
sData1 =(str(seizS:seizE,1));
%filter
fNorm = 50/(freq/2);
[b, a] = butter(5, [49 51]./(freq/2), 'stop');
filtStr = filtfilt(b, a, str);
filtsData1 = filtfilt(b, a, sData1);

%calculate energy
llStr = [0; cumsum(abs(diff(filtStr)))];
llData1 = [0 ;cumsum(abs(diff(filtsData1)))];
%plot of all
plot(time, llStr);
xlabel('Time(sec)');
ylabel('Voltage(Hz)');
%plot of just seizure
hold
plot(timeS,llData1, 'r');
title(['Power Signal - Electrode' num2str(sect) '.' num2str(chan)]);
%xlim([0 size/freq]);