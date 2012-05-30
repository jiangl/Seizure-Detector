% 		EEG seizure onset (sample)     	EEG seizure end (sample)
% 
% 010516da_0013 	913926				917760
% 010516da_0024 	81193				88326
% 010516da_0026 	533766				537470
% 010516da_0033 	845197				849107
% 010518da_0002 	882483				921351
% 
% ----------
% Electrodes
% ----------
% InFokus1	G_A3
% InFokus2	G_A4
% InFokus3	IHB4
% OutFokus1	G_D1
% OutFokus2	IHB1
% OutFokus3	LL1
%%
load 010516da_0013_1.asc;
load 010516da_0013_2.asc;
load 010516da_0013_3.asc;
load 010516da_0013_4.asc;
load 010516da_0013_5.asc;
load 010516da_0013_6.asc;

%TIME VECTORS
freq = 256;
%entire plot
time = linspace(0,921600/freq, 921600);
%time vector of seizure
timeS = linspace(913926/freq, 917760/freq, 917760-913926+1);

%PLOT ALL 6 ELECTRODE CHANNELS 
for i = 1:6
%seizure values
str = eval(['X010516da_0013_' num2str(i)]);
sData1 =(str(913926:917760,1));
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
sFile = ['010516da_0013_'; 
        '010516da_0023_';
        '010516da_0024_';
        '010516da_0025_';
        '010516da_0026_';
        '010516da_0033_';
        '010516da_0034_'];
    
sName = ['X010516da_0013_';
        'X010516da_0023_';
        'X010516da_0024_';
        'X010516da_0025_';
        'X010516da_0026_';
        'X010516da_0033_';
        'X010516da_0034_'];
%%
chann = 2; 
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
time = linspace(0, (size/freq)*7, 460800*7);
plot(time, finalSig);
xlim([0 25200]);
xlabel('Time(sec)');
ylabel('Voltage(Hz)');
title(['Total Time Signal - Channel' num2str(chann)]);
%%
% 		EEG seizure onset (sample)     	EEG seizure end (sample)
% 
% 010516da_0013 	913926				913926
% 010516da_0024 	81193				921600*2 + 81193 = 1924393
% 010516da_0026 	533766				921600*4 + 533766 = 4220166
% 010516da_0033 	845197				921600*5 + 845197 = 5453197

Seize = zeros(4, 1);
Seize(1, 1) = 913926;
Seize(2, 1) = 1924393;
Seize(3, 1) = 4220166;
Seize(4, 1) = 5453197;
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
plot(time, llFeat*2*max(data)/max(llFeat), 'b')
xlabel('Time(s)');
ylabel('Voltage(Hz)'); %All (scaled + offset) on EEG
    %legend('Total Signal', 'Line-Length Feature');
    %hold off
hold on
%plot actual seizure locations
for i = 1:length(Seize)
   plot([Seize(i)/256 Seize(i)/256], [0 120000], 'k');
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
thresh = 1.5*10^5;
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
   plot([Seize(i)/256 Seize(i)/256], [0 120000], 'k');
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
