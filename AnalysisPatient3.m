
% 
% ----------
% Electrodes
% ----------
% InFokus1	FE1
% InFokus2	FE2
% InFokus3	FD1
% OutFokus1	G_F8
% OutFokus2	G_G8
% OutFokus3	G_H8
%% Patient 3: DATA SET
sFile = ['010503ba_0104_';
        '010503ba_0105_'; 
        '010503ba_0124_';
        '010503ba_0125_';
        '010503ba_0126_';
        '010503ba_0127_';
        '010503ba_0174_';
        '010503ba_0175_'];
sName = ['X010503ba_0104_';
        'X010503ba_0105_'; 
        'X010503ba_0124_';
        'X010503ba_0125_';
        'X010503ba_0126_';
        'X010503ba_0127_';
        'X010503ba_0174_';
        'X010503ba_0175_'];
    
%USER INPUT
chann = 2; 
%LOAD CORRECT FILES
for i = 1:8
    str = [sFile(i,:) num2str(chann) '.asc'];
    load (str);
end

%TIME VECTORS
freq = 256;
%entire plot
time = linspace(0,921600/freq, 921600);
%time vector of seizure
timeS = linspace(620181/freq, 647989/freq, 647989-620181+1);

%PLOT ALL 6 ELECTRODE CHANNELS 
for i = 1:6
%seizure values
str = eval(['X010503ba_0105_' num2str(i)]);
sData1 =(str(620181:647989,1));
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
%%
chann = 2; 
%LOAD CORRECT FILES
for i = 1:8
    str = [sFile(i,:) num2str(chann) '.asc'];
    load (str);
end

%finalSig = zeros(size(sFile)*921600,1);
finalSig = [];
for i = 1:8
    
%VARIABLES
size = 921600;
freq = 256;

%CALCULATE 
% seizS = sLoc(i, 1);
% seizE = sLoc(i, 2);

%PLOT ALL 6 ELECTRODE CHANNELS --- TIME SIGNAL
%figure();

%seizure values
str = eval([sName(i,:) num2str(chann)]);
    %sData1 =(str(seizS:seizE,1));

%insert filters here
[b, a] = butter(5, [49 51]./(freq/2), 'stop');
filtStr = filtfilt(b, a, str);
    %filtsData1T = filtfilt(b, a, sData1);

%downsample data
dStr = decimate(filtStr, 2);
finalSig = [finalSig; dStr];
dtime = linspace(0,size/freq, size/2);
figure();
plot(dtime, dStr);
%xlabel('Time(sec)');
%ylabel('Voltage(Hz)');
%title(['Time Signal - Electrode' num2str(i) '.' num2str(chann)]);
%xlim([0 size/freq ]);
    
end

figure()
time = linspace(0, (size/freq)*8, 460800*8);
plot(time, finalSig);
xlim([0 25200]);
xlabel('Time(sec)');
ylabel('Voltage(Hz)');
title(['Total Time Signal - Channel' num2str(chann)]);
%%
% 		EEG seizure onset (sample)     	EEG seizure end (sample)
% 
% 010503ba_0105 	620181				921600 + 620181 = 1541781
% 010503ba_0125 	71548				921600*3 + 71548 = 2836348
% 010503ba_0127 	347776				921600*5 + 347776 = 4955776
% 010503ba_0174 	891989				921600*6 + 891989 = 6421589
% 010503ba_0176 	51836				921600*8 + 51836 = 7424636
Seize = zeros(5, 1);
Seize(1, 1) = 1541781;
Seize(2, 1) = 2836348;
Seize(3, 1) = 4955776;
Seize(4, 1) = 6421589;
Seize(5, 1) = 7424636;

%% Calculate Line Length
data = finalSig;
frequency = 256/2;
L = 10;
d = 1; 
time = linspace(0, (size/freq)*8, 460800*8);

figure();
    %plot(time, data);
    %hold on
%line length feature with rf = running feature and ni = number ignored from
%left
[rf,ni] = rfeature(data,inline('sum(abs(diff(data)))'),L*frequency,d*frequency);
%scales up the graph/aligns
llFeat = [NaN(1, ni+L*frequency-1) zohinterp(rf(1:end-1), d*frequency) rf(end)];
%normalize
plot(time, llFeat*2*max(data)/max(llFeat), 'b')
xlabel('Time(s)');
ylabel('Voltage(Hz)'); %All (scaled + offset) on EEG
    %legend('Total Signal', 'Line-Length Feature');
    %hold off
hold on
%plot actual seizure locations
for i = 1:length(Seize)
   plot([Seize(i)/256 Seize(i)/256], [0 80000], 'k');
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
    plot([Peaks(i) Peaks(i)], [0 80000], 'r');
end
xlabel('Time(s)');
ylabel('Voltage(Hz)');
title('Line Length Seizure Detection');
%legend('Actual Seizure', 'Predicted Seizure', 'Signal');
xlim([0 25200]);
hold off
