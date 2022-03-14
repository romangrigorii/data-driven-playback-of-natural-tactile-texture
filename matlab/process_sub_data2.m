function R = process_sub_data2(expe,subj,texture,ss,ee,tria,gain)

S = load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe,'_x.mat'));
sr = S.sr;

[b1,a1] = butter(1,20*2/sr,'low');
[b2,a2] = butter(1,2*[10,800]/sr,'bandpass');
veld = 40;
latC = 4/9; % in N/V
R = [];


S = load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe,'_',tria,'.mat'));
dataQ = S.dataQ;

counterNBits = 32;
signedThreshold = 2^(counterNBits-1);
signedData = dataQ(:,5);
signedData(signedData > signedThreshold) = signedData(signedData > signedThreshold) - 2^counterNBits;
pos= filtfilt(b1,a1,signedData * 5/10000);
vel = derivR(pos,1,sr);

lat = dataQ(:,1)*latC;
lat = lat - linspace(lat(1),lat(end),length(lat)).';
latf = filtfilt(b2,a2,lat);
lat1 = latf(vel<-(veld-2)); % lat1 is used to estimate noise
lat2 = latf(vel>(veld-2)); % lat2 is used to extract texture data
lat3 = lat(vel>(veld-2)); % lat3 is used to extract finger dynamics

latnoi = lat1(1:sr);
lattex = latf(ee-sr:ee-1);

lattex = real(ifft((abs(fft(lattex))-abs(fft(latnoi))).*exp(sqrt(-1)*atan2(imag(fft(lattex)),real(fft(lattex))))));
close all
subplot(2,1,1);
hold on
plot(texture);
plot(lattex/gain);
subplot(2,1,2);
hold on
plot(texture);
plot(lattex);
corr(texture.',lattex)
end
