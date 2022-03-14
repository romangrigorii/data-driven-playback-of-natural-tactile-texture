function [out1,out2] = process_sub_data3(expe,subj,texture,ss,ee,trial,show)

S = load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe, '_x.mat'));
sr = S.sr;

[b1,a1] = butter(1,20*2/sr,'low');
[b2,a2] = butter(1,2*[10,1000]/sr,'bandpass');
veld = 40;
latC = 4/9; % in N/V
R = [];

ff1 = linspace(1,10000,5000);
ff2 = logspace(log10(20),log10(1000),100);

ldvC = 50/4/1000; % in m/V
norC = .31; % in N/V

S = load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe,'_',trial,'.mat'));
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
lattex = latf(ee-sr+1:ee);

lattex = real(ifft((abs(fft(lattex))-abs(fft(latnoi))).*exp(sqrt(-1)*atan2(imag(fft(lattex)),real(fft(lattex))))));

nor = dataQ(:,2);
nor = norC*(nor - linspace(nor(sr),nor(end),length(nor)).');
norf = filtfilt(b1,a1,nor);
nor1 = norf(vel<-(veld-2));
nor2 = norf(vel>(veld-2));

sig1 = interp1(ff1,abs(fft(lattex(2501:7500))),ff2);
sig2 = interp1(ff1,abs(fft(texture(2501:7500))),ff2);
out1 = 2.^mean(log2(sig1)-log2(sig2));

out2 = corr(texture.',lattex).^2;

if show
    close all
    subplot(2,1,1);
    hold on
    plot(texture);
    plot(lattex/out1);
    subplot(2,1,2);
    hold on
    plot(texture);
    plot(lattex);
end

end
