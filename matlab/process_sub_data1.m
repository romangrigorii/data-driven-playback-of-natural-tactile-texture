function [SIGI_lat,SIGI_vib,SIGIs,SIGO,ss,ee] = process_sub_data1(expe,subj,showplot)

S = load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe,'_x.mat'));
dur = S.dur;
freqs = S.freqs;
freqsi = S.freqsi;
sr = S.sr;

[b1,a1] = butter(1,150*2/sr,'low');
[b2,a2] = butter(1,2*[10,1000]/sr,'bandpass');
[bs,as] = butter(1,[1800,2200]*2/sr,'stop');
veld = 40;
magT = [];
phaT = [];
reaT = [];
imaT = [];
ff = [];
textures = {};
T = [];
vels = [];

ldvC = 50/4/1000; % in m/V
latC = 4/9; % in N/V
norC = .31; % in N/V

for t = 1:7
    tria = num2str(t);
    
    S = load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe,'_',tria,'.mat'));
    dataQ = S.dataQ;
    
    counterNBits = 32;
    signedThreshold = 2^(counterNBits-1);
    signedData = dataQ(:,5);
    signedData(signedData > signedThreshold) = signedData(signedData > signedThreshold) - 2^counterNBits;
    pos= filtfilt(b1,a1,signedData * 5/10000);
    vel = derivR(pos,1,sr);    
   
    lat = filter(bs,as,dataQ(:,1)*latC);
    lat = lat - linspace(lat(1),lat(end),length(lat)).';
    latf = filtfilt(b2,a2,lat);    
    lat1 = latf(vel<-(veld-1)); % lat1 is used to estimate noise
    lat2 = latf(vel>(veld-1)); % lat2 is used to extract texture data
    lat3 = lat(vel>(veld-1)); % lat3 is used to extract finger dynamics
    
    latnoi = lat1(1:sr);
    lattex = lat2(1:sr);
    latele = detrend(lat3(end-sr/2:end));    
    lattex = real(ifft((abs(fft(lattex))-abs(fft(latnoi))).*exp(sqrt(-1)*atan2(imag(fft(lattex)),real(fft(lattex))))));
    
    cur = dataQ(:,4);
    cur3 = cur(vel>(veld-1));
    curele = cur3(end-sr/2:end);
    
    nor = dataQ(:,2);
    nor = norC*(nor - linspace(mean(nor(1:sr)),mean(nor(end-sr/4:end)),length(nor)).');
    norf = filtfilt(b1,a1,nor);
    nor1 = norf(vel<-(veld-1));
    nor2 = norf(vel>(veld-1));
    
    ldv = -dataQ(:,3)*ldvC;
    ldvf = filtfilt(b2,a2,ldv);
    ldv1 = ldvf(vel<-(veld-1));
    ldv2 = ldvf(vel>(veld-1));
    ldv3 = ldv(vel>(veld-1));
    
    ldvnoi = ldv1(1:sr);
    ldvtex = ldv2(1:sr);
    ldvele = detrend(ldv3(end-sr/2:end));       
    ldvtex = real(ifft((abs(fft(ldvtex))-abs(fft(ldvnoi))).*exp(sqrt(-1)*atan2(imag(fft(ldvtex)),real(fft(ldvtex))))));
    
    tt = (0:(length(latele)-1))/sr;
    
    ff(t) = freqs(freqsi(t));
    
    cc = cos(2*pi*tt*ff(t));
    ss = sin(2*pi*tt*ff(t));
    
    latelec = 2*latele.*cc.';
    lateles = 2*latele.*ss.';
    ldvelec = 2*ldvele.*cc.';
    ldveles = 2*ldvele.*ss.';
    curelec = 2*curele.*cc.';
    cureles = 2*curele.*ss.';
    
    divVL = divide_complex(median(ldvelec),median(ldveles),median(latelec),median(lateles));
    divLC = divide_complex(median(latelec),median(lateles),median(curelec),median(cureles));
    
    L = round(length(divVL)/2);
    T(t) = mean(real(divVL)) + sqrt(-1)*mean(imag(divVL));
    P(t) = mean(real(divLC)) + sqrt(-1)*mean(imag(divLC));
    
    magT(t) = mean(abs(divVL));
    phaT(t) = -mean(atan2(imag(divVL),real(divVL)));
    magP(t) = mean(abs(divLC));
    phaP(t) = -mean(atan2(imag(divLC),real(divLC)));
    
    textures{t} = [lattex,ldvtex];
    
    vels = [vels,vel];
end

textures{8} = zeros(sr,2);

[k,l] = sort(ff);
T = T(l);
P = P(l);
ff = ff(l);
magT = magT(l);
phaT = phaT(l);
magP = magP(l);
phaP = phaP(l);

if showplot == 1
    subplot(2,1,1);
    plot(freqs,magP)
    ylabel('force/current (N/mA)')
    set(gca,'Xscale','log')
    subplot(2,1,2);
    plot(freqs,phaP);
    ylabel('phase (rad)');
    xlabel('frequency (Hz)');
    set(gca,'Xscale','log')
end
%% creating sigs

inds = 1:length(vels);
velm = mean(vels.');
indsvel = inds(velm>(veld-1))+1000;
indsvela = indsvel(end-sr:end-1);

if exist(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe,'_xx.mat')) == 2
    s = load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe,'_xx.mat'));
    lpfreq = s.lpfreq;
else
    lpfreq = 250;
    save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\data\subject data\',subj,'\',expe,'_xx.mat'),'lpfreq');
end

bb = [1 (lpfreq*2*pi)]*1000/lpfreq;
aa = [1 (1000*2*pi)];
[b,a] = stoz(bb,aa,sr);
bb = [(lpfreq*2*pi)];
aa = [1 (lpfreq*2*pi)];
[k,l] = bode(bb,aa,freqs*2*pi);

if showplot == 1
    subplot(2,1,1);
    hold on
    plot(freqs,k*magP(1));
    subplot(2,1,2);
    hold on
    plot(freqs,l/180*pi);
end

SIGO = {};
SIGI_lat = {};
SIGI_vib = {};
SIGIs = {};

for i = 1:7
    SIGO{i} = zeros(1,sr*dur);
    tex = textures{i}(:,1).';
    SIGI_lat{i} = tex;   
    SIGI_vib{i} = textures{i}(:,2).'; 
    tex = filter(b,a,tex)/magP(1);
    SIGIs{i} = tex;
    SIGO{i}(indsvela) = tex;
end
SIGI_lat{8} = textures{8}(:,1).';
SIGI_vib{8} = textures{8}(:,2).';
ss = indsvel(1);
ee = indsvel(end);

end
