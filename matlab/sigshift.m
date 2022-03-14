function sigo = sigshift(sigi,sr,freqs,bw,amps,phases)
t = linspace(0,1,sr);
sigo = zeros(size(sigi));
for f = 1:length(freqs)
    [b,a] = butter(1,bw*freqs(f)*2/sr,'low');
    s1 = 2*filter(b,a,sigi.*sin(2*pi*freqs(f)*t)).*sin((2*pi*freqs(f)*t) + phases(f))*amps(f);
    c1 = 2*filter(b,a,sigi.*cos(2*pi*freqs(f)*t)).*cos((2*pi*freqs(f)*t) + phases(f))*amps(f);
    sigo = s1 + c1 + sigo;
end
% [b,a] = butter(2,5*2/sr,'low');
% sigo = filter(b,a,abs(sigi))./filter(b,a,abs(sigo)).*sigo*amps(1);
end

% sigi = randn(1,sr);
% [b,a] = butter(2,2*[20,800]/sr,'bandpass');
% sigi = filter(b,a,sigi);
% [b,a] = butter(1,(freqs(end)*(1+bw))*2/sr,'low');
% sigi = filter(b,a,sigi);
