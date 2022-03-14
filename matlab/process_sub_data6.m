function [gaL,gaR] = process_sub_data6(expe,subj,textures,ss,ee,trial,tex_gains,randmats,show)

S = load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe, '_x.mat'));
sr = S.sr;

ff1 = linspace(1,10000,3000);
ff2 = logspace(log10(20),log10(1000),100);

[b1,a1] = butter(1,20*2/sr,'low');
[b2,a2] = butter(2,2*[10,1000]/sr,'bandpass');
veld = 40;
latC = 4/9; % in N/V
R = [];

ldvC = 50/4/1000; % in m/V
latC = 4/9; % in N/V
norC = .31; % in N/V

S = load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe,'_',num2str(trial),'.mat'));
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
lat1 = latf(vel<-(veld-1)); % lat1 is used to estimate noise
lat2 = latf(vel>(veld-1)); % lat2 is used to extract texture data
lat3 = lat(vel>(veld-1)); % lat3 is used to extract finger dynamics

sig1 = log2(interp1(ff1,abs(fft(lat2(3001:6000))),ff2));
sig2 = log2(interp1(ff1,abs(fft(lat2(17001:20000))),ff2));


if randmats(trial,3) == 0
    tex1 = log2(interp1(ff1,abs(fft(textures{randmats(trial,2)}(3501:6500))),ff2));
    gaR = (2^mean(sig1 - tex1))/tex_gains{randmats(trial,2)};
    if randmats(trial,1)<8
        tex2 = log2(interp1(ff1,abs(fft(textures{randmats(trial,1)}(3501:6500))),ff2));
        gaL = (2^mean(sig2 - tex2))/tex_gains{randmats(trial,1)};
    else
        gaL = -1;
    end
else
    tex2 = log2(interp1(ff1,abs(fft(textures{randmats(trial,2)}(3501:6500))),ff2));
    gaL = (2^mean(sig2 - tex2))/tex_gains{randmats(trial,2)};
    if randmats(trial,1)<8
        tex1 = log2(interp1(ff1,abs(fft(textures{randmats(trial,1)}(3501:6500))),ff2));
        gaR = (2^mean(sig1 - tex1))/tex_gains{randmats(trial,1)}
    else
        gaR = -1;
    end    
end

% lattex = real(ifft((abs(fft(lattex))-abs(fft(latnoi))).*exp(sqrt(-1)*atan2(imag(fft(lattex)),real(fft(lattex))))));
% lattexo = real(ifft((abs(fft(lattexo))-abs(fft(latnoi))).*exp(sqrt(-1)*atan2(imag(fft(lattexo)),real(fft(lattexo))))));
% 
nor = dataQ(:,2);
nor = norC*(nor - linspace(nor(sr),nor(end),length(nor)).');
norf = filtfilt(b1,a1,nor);
nor1 = norf(vel<-(veld-2));
nor2 = norf(vel>(veld-2));
% 
% if show
%     close all
%     subplot(2,1,1);
%     hold on
%     
%     tex_num = randmats(trial,2);
%     
%     plot(textures{tex_num});
%     if tex_num<8
%         plot(lattex/(tex_gains{tex_num}(end)));
%     end
%     subplot(2,1,2);
%     hold on
%     plot(textures{tex_num});
%     plot(lattex);
%     corr(textures{tex_num}(sr/4:sr*3/4).',lattex(sr/4:3*sr/4))
% end

end
