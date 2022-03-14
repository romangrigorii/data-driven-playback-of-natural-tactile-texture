%% initialize
dur = 3;
sr = 100000;
hz = 200;
t = linspace(0,dur,sr*dur);
st = daq.createSession('ni');
st.Rate = sr;
st.DurationInSeconds = dur;
ch1 = addAnalogInputChannel(st,'Dev1','ai1','Voltage');
ch1.InputType = 'SingleEnded'; %% lateral force
ch2 = addAnalogInputChannel(st,'Dev1','ai9','Voltage');
ch2.InputType = 'SingleEnded'; %% lateral force
ch6 = addAnalogOutputChannel(st,'Dev1','ao1','Voltage');
sig = 3*sin(2*pi*hz*t);
sig(end) = 0;
queueOutputData(st,sig.');

%% fit

fun = @(x,xdata)x(1)*sin(2*pi*t(2*sr+1:end)*hz + x(2)) + x(3)*sin(2*pi*3*t(2*sr+1:end)*hz + x(4));
x = lsqcurvefit(fun,[1,1,1,1],sig(2*sr+1:end),out(2*sr+1:end,1).')
%%

[b1,a1] = butter(1,50*2/sr,'low');
counterNBits = 32;
signedThreshold = 2^(counterNBits-1);
signedData = out(:,2);
signedData(signedData > signedThreshold) = signedData(signedData > signedThreshold) - 2^counterNBits;
pos= filtfilt(b1,a1,signedData * 5/10000);

%%
dur = 10;
sr = 75000;
st = daq.createSession('ni');
st.Rate = sr;
st.DurationInSeconds = dur;
ch1 = addAnalogInputChannel(st,'Dev2','ai1','Voltage');
ch1.InputType = 'SingleEnded'; %% lateral force
ch2 = addAnalogInputChannel(st,'Dev2','ai3','Voltage');
ch2.InputType = 'SingleEnded'; %% current
ch3 = addAnalogOutputChannel(st,'Dev2','ao0','Voltage');
%lh = addlistener(st,'DataAvailable', @saveDAQdata);

%%
%initialize DAQ recording in background

lh = addlistener(st,'DataAvailable', @saveDAQdata);
st.NotifyWhenDataAvailableExceeds = int32(sr*dur);

%start recording
st.startBackground(); %start recording from DAQ

%% begin sampling
freq = 300;
tt = linspace(0,dur,sr*dur);
%sig = (sin(2*pi*freq*tt)+2.5).*sin(2*pi*10000*tt);
sig = 1*sin(2*pi*freq*tt);
sig = chirp(tt,20,dur,1000,'log');
%sig = (sin(2*pi*freq*tt)>0)*2 - 1;
sig(end) = 0;

queueOutputData(st,sig.');


% removeChannel(st,3);
% ch3 = addAnalogOutputChannel(st,'Dev2','ao0','Voltage');
% queueOutputData(st,sig.');
% st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
% st.startBackground();

x = input('make sure to turn on the camera and set the normal stage and closed the curtain\n');
out = startForeground(st);
%% compute phase
[b,a] = butter(2,2*10/sr,'low');
[b2,a2] = butter(2,1000*2/sr,'low');
[b3,a3] = butter(2,[10,1000]*2/sr,'bandpass');
[bb,aa] = butter(2,2/sr*freq*[.5 2],'bandpass');

% out(:,2) = filtfilt(b2,a2,abs(out(:,2)));

s = sin(2*pi*freq*tt).';
c = cos(2*pi*freq*tt).';

Ls = filtfilt(b,a,2*s.*abs(out(:,1)));
Lc = filtfilt(b,a,2*c.*abs(out(:,1)));
Is = filtfilt(b,a,2*s.*sig.');
Ic = filtfilt(b,a,2*c.*sig.');


hold on
plot(tt,atan2(Ls,Lc)-atan2(Is,Ic));
plot(tt,sqrt(Ls.^2 + Lc.^2)*10);



%% 

        counterNBits = 32;
        signedThreshold = 2^(counterNBits-1);
        signedData = out(:,5);
        signedData(signedData > signedThreshold) = signedData(signedData > signedThreshold) - 2^counterNBits;
        positionData = signedData * 5/10000;
        out(:,5) = positionData;
        %DATA{s,rana(a),ranf(f),d,1} = out;
        %DATA{s,rana(a),ranf(f),d,2} = [amps(rana(a)),freqs(ranf(f)),offset];