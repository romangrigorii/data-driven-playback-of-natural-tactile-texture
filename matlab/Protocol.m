addpath(genpath('C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction'));
addpath(genpath('C:\Users\atrox\Desktop\Work\Research\Code'));

%% init PIC and DAQ
clear all

dirr = 'C:\Users\atrox\Desktop\Work\Research\My projects\Finished project\Data-driven playback of natural tactile texture via broadband friction\code\matlab\DAQ\data\';

subj = '25';
if ~isempty(instrfind)
    fclose(instrfind);
end

create_rand_comp();

enc_val = 0;

port = serial('COM7', 'BaudRate', 230400, 'FlowControl', 'hardware');
fopen(port);
fprintf(port,'\n');
v = fscanf(port);

% motor engage / disengage
fprintf(port,'m');
v = fscanf(port);
% turn feedback on
% fprintf(port,'g');
% zero everything
fprintf(port,'z');
v = fscanf(port);

% init session
clear ch1 ch2 ch3 ch4 ch5 ch6 st lh
ch_init();

%% checkng that the finger clears side of tribometer
position = -30000;
move_stage(port,position,1);
while enc_val<(position)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.01);
end

%% adjusting normal load

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);
if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

move_stage(port,90000,1);
while enc_val<(90000)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.1);
end

fprintf(port,'1');
v = fscanf(port);
move_trib(port,1100);
pause(3);

x = input('press enter when normal load is at desired range\n');

fprintf(port,'1');
v = fscanf(port);
move_trib(port,0);
pause(3);

move_stage(port,(7000),1);
while enc_val>(7000)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.1);
end


%% experiment 1 - capture

% initilizing

freqs = logspace(log10(20),log10(1000),7);
freqsi = [3,7,2,6,1,5,4];
expp = exp1;
expe = '1';
PP = [];
tim = linspace(0,dur,sr*dur);
%save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'freqs','freqsi','sr','dur');

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);
if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

fprintf(port,'p');
v = fscanf(port);
v = fscanf(port);
enc_val = str2num(v);

for tc = 1:length(freqs)

    while (expp.enter == 0)
        pause(.1);
    end    
    
    delete('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\data_temp.mat');
    
%     removeChannel(st,6);
%     ch6 = addAnalogOutputChannel(st,'Dev2','ao0','Voltage');

    lh = addlistener(st,'DataAvailable', @saveDAQdata);
    sig = 1.5*sin(2*pi*freqs(freqsi(tc))*tim).';
    sig(end) = 0;
    sig(sig>5) = 5;
    sig(sig<-5) = -5;
    release(st)
    queueOutputData(st,sig);
    st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
    st.startBackground();
    
    move_stage(port,90000,1);
    while enc_val<(90000)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);
    end
    
    fprintf(port,'1');
    v = fscanf(port);
    move_trib(port,1100);
    
    pause(2);
    
    move_stage(port,(7000),1);
    
    while enc_val>(7000)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);
    end
    
    fprintf(port,'1');
    v = fscanf(port);
    move_trib(port,0);
    
    while length(dir(dirr)) == 2
        pause(.01);
    end
    
    stat = 0;
    tmr = timer('TimerFcn', 'stat=true;' ,'StartDelay',2);
    start(tmr)
            
    while stat == 0
        pause(.01);
    end
    
    ready = 0;
    while ready == 0
        fprintf(port,'b');
        v = fscanf(port);
        v = fscanf(port);
        ready = str2num(v);
        pause(.01);
    end
        
    fprintf(port,'a');
    v = fscanf(port);    
   
    expp.ready = 1;
    expp.enter = 0;
    expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
    expp.PresstoSwipeButton.Text = 'Press to Swipe';    
    
    %process_temp_data(expe,subj,num2str(tc));
    
    tc
end

%save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'freqs','freqsi','sr','dur');
%[textures_lat,textures_vib,textures_processed,textures_processed,ss,ee] = process_sub_data1(expe,subj,1);

%% experiment 2 - volume play
% initializing

expp = exp2;
gains = [0,1,2,3];
expe = '2';

tn = 1;

% clearing buffer

% while get(port,'BytesAvailable')>0
%     v = fscanf(port,1);
% end

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);
if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

show = 0;

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur');

for g = 1:length(gains)

    
    expp.gain = gains(g);
    expp.EditField.Value = gains(g);
    expp.GAINSlider.Value = gains(g);
    
    while (expp.again == 0)
        pause(.01);
    end
    
    close all
    
    delete('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\data_temp.mat');
    lh = addlistener(st,'DataAvailable', @saveDAQdata);
    sig = (2^gains(g))*textures_processed{tn}.';
    sig(end) = 0;
    sig(sig>5) = 5;
    sig(sig<-5) = -5;
    release(st)
    queueOutputData(st,sig);
    st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
    st.startBackground();   
    
    move_stage(port,90000,1);
    while enc_val<(90000)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);
    end
    
    fprintf(port,'1');
    v = fscanf(port);
    move_trib(port,1100);
    
    pause(2);
    
    move_stage(port,(7000),1);
    
    while enc_val>(7000)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);   
    end
    
    fprintf(port,'1');
    v = fscanf(port);
    move_trib(port,0);
    
    while length(dir(dirr)) == 2
        pause(.01);
    end
    
    stat = 0;
    tmr = timer('TimerFcn', 'stat=true;' ,'StartDelay', 2);
    start(tmr)
    
    while stat == 0
        pause(.01);
    end    
   
    expp.again = 0;
    expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
    expp.PresstoSwipeButton.Text = 'Swipe again';       
   
    process_temp_data(expe,subj,num2str(g));
    
    if show
        process_sub_data2(expe,subj,textures_lat{tn},ss,ee,num2str(g),2^gains(g));
    end
end

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur');

%% experiment 3 - volume adjust
% initializing

expp = exp3;
tex_trial = zeros(1,7);
tex_gains = {};
tex_gainsa = {};
expe = '3';

% clearing buffer

while get(port,'BytesAvailable')>0
    v = fscanf(port);
end

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);
if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

show = 0;

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_gains','tex_trial');

for tc = 1:7
    
    tex_gains{tc} = [];
    tex_gainsa{tc} = [];
    cors3{tc} = [];
    expp.tex.Text = strcat('Presenting Texture '," ",num2str(tc));
    
    while expp.next == 0
        
        while expp.again == 0
            pause(.01);
        end

        if expp.next == 0
           
            tex_gains{tc} = [tex_gains{tc},expp.GAINSlider.Value]; 
            
            delete('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\data_temp.mat');
            lh = addlistener(st,'DataAvailable', @saveDAQdata);
            sig = (2^expp.gain)*textures_processed{tc}.';
            sig(end) = 0;
            sig(sig>5) = 5;
            sig(sig<-5) = -5;
            release(st)
            queueOutputData(st,sig);
            st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
            st.startBackground();
            
            move_stage(port,90000,1);
            while enc_val<(90000)
                fprintf(port,'p');
                v = fscanf(port);
                v = fscanf(port);
                enc_val = str2num(v);
                pause(.01);
            end
            
            fprintf(port,'1');
            v = fscanf(port);
            move_trib(port,1100);
            pause(2);
            
            move_stage(port,(7000),1);
            while enc_val>(7000)
                fprintf(port,'p');
                v = fscanf(port);
                v = fscanf(port);
                enc_val = str2num(v);
                pause(.01);
            end
            
            fprintf(port,'1');
            v = fscanf(port);
            move_trib(port,0);            
            
            expp.again = 0;
            expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
            expp.PresstoSwipeButton.Text = 'Press to Swipe';
            
            tex_trial(tc) = tex_trial(tc) + 1;
        end        
    end       
    
    while length(dir(dirr)) == 2
        pause(.01);
    end
    
    stat = 0;
    tmr = timer('TimerFcn', 'stat=true;' ,'StartDelay',2);
    start(tmr)
    
    while stat == 0
        pause(.01);
    end    
   
    ready = 0;
    
    fprintf(port,'a');
    v = fscanf(port);
    
    while ready == 0
        fprintf(port,'b');
        v = fscanf(port);
        v = fscanf(port);
        ready = str2num(v);
        pause(.01);
    end
    
    fprintf(port,'a');
    v = fscanf(port);
    
    if mod(tc,3) == 0
        clear ch1 ch2 ch3 ch4 ch5 ch6 st lh
        ch_init();
    end
    
    expp.next = 0;
    expp.again = 0;
    expp.FinishedAdjustingButton.BackgroundColor = [.96 .96 .96];
    expp.FinishedAdjustingButton.Text = 'Finished Adjusting';
    expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
    expp.PresstoSwipeButton.Text = 'Swipe Again';
    
    expp.gain = -1;
    expp.GAINSlider.Value = 0;
    expp.EditField.Value = 0;
    
    process_temp_data(expe,subj,num2str(tc));
    
    [actual_gain,cors] = process_sub_data3(expe,subj,textures_lat{tc},ss,ee,num2str(tc),show);
    
    tex_gainsa{tc} = [tex_gainsa{tc},actual_gain];

end

for tc = 1:7
    tex_gainsa{tc} = [];
    [actual_gain,cors] = process_sub_data3(expe,subj,textures_lat{tc},ss,ee,num2str(tc),show);
    tex_gainsa{tc} = [tex_gainsa{tc},actual_gain];
end

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_gains','tex_gainsa','tex_trial');
textures_processed_6 = process_sub_data_pre6('1',subj,randmats,tex_gainsa);

%% experiment 6 - load double screen

move_stage(port,-30000,1);
while enc_val<(-30000)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.01);
end

%% experiment 6 - move the stage to surface start

move_stage(port,(-7000),1);
while enc_val>(-7000)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.01);
end
            
%% expriment 6 - identify which texture is closest real vs virtual
% init

gaRvec = [];
gaLvec = [];
gaR = 1;
gaL = 1;
midc = round((ss+ee)/2);

create_rand_comp();

proxim_mat = 2*ones(8,7);
trial = 1;
tex_trial_3 = zeros(8,7);

expp = exp6;
expe = '6';

% clear buffer

if get(port,'BytesAvailable')>0
    v = fscanf(port);
end

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);

if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

clear ch1 ch2 ch3 ch4 ch5 ch6 st lh
ch_init();

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_trial_3','proxim_mat','randmat_3','randmats');

show = 0;

for tc = 1:49
    
    expp.tex.Text = strcat('Presenting Texture Combination '," ",strcat(num2str(tc)),'/49');   
    
    randmat_3(tc,3)
    
    while expp.next == 0
        
        while expp.again == 0
            pause(.01);
        end
       
        if expp.next == 0            
           
            delete('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\data_temp.mat');
            
            lh = addlistener(st,'DataAvailable', @saveDAQdata);
                
            sig = textures_processed_6{tc};
            sig1 = sig(1:midc);
            sig1(sig1>-4.9) = sig1(sig1>-4.9)*gaR;
            sig2 = sig(midc:end);
            sig2(sig2>-4.9) = sig2(sig2>-4.9)*gaL;
            sig(1:midc) = sig1;
            sig(midc:end) = sig2;
            
            sig(end) = 0;
            sig(sig>5) = 5;
            sig(sig<-5) = -5;
            release(st)
            queueOutputData(st,sig);
            st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
            st.startBackground();
            
            move_stage(port,90000,1);
            while enc_val<(90000)
                fprintf(port,'p');
                v = fscanf(port);
                v = fscanf(port);
                enc_val = str2num(v);
                pause(.01);
            end
            
            fprintf(port,'1');
            v = fscanf(port);
            move_trib(port,1100);
            pause(2);
                        
            move_stage(port,(7000),1);
            while enc_val>(7000)
                fprintf(port,'p');
                v = fscanf(port);
                v = fscanf(port);
                enc_val = str2num(v);
                pause(.01);
            end
            
            fprintf(port,'1');
            v = fscanf(port);
            move_trib(port,0);
            
            pause(2);
                        
            expp.again = 0;
            expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
            expp.PresstoSwipeButton.Text = 'Press to Swipe';   
            
            pause(.01)
            
            tex_trial_3(randmat_3(tc,1),randmat_3(tc,2)) = tex_trial_3(randmat_3(tc,1),randmat_3(tc,2)) + 1;
        end
    end
    
    proxim_mat(randmat_3(tc,1),randmat_3(tc,2)) = expp.answer;
    
    while length(dir(dirr)) == 2
        pause(.01);
    end
    
    stat = 0;
    t = timer('TimerFcn', 'stat=true;' ,'StartDelay',2);
    start(t)

    while stat == 0
        pause(.01)
    end
       
    if mod(tc,10) == 0
        clear ch1 ch2 ch3 ch4 ch5 ch6 st lh
        ch_init();
    end
    
    ready = 0;
    
    fprintf(port,'a');
    v = fscanf(port);
    
    while ready == 0
        fprintf(port,'b');
        v = fscanf(port);
        v = fscanf(port);
        ready = str2num(v);
        pause(.01);
    end
    
    fprintf(port,'a');
    v = fscanf(port);
    
    expp.next = 0;
    expp.again = 0;
    expp.FinishedAnsweringButton.BackgroundColor = [.96 .96 .96];
    expp.FinishedAnsweringButton.Text = 'Finished Adjusting';
    expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
    expp.PresstoSwipeButton.Text = 'Swipe Again';
    
    expp.RIGHTcomes1stButton.BackgroundColor = [.96 .96 .96];
    expp.LEFTcomes2ndButton.BackgroundColor = [.96 .96 .96];
    expp.answer = 2;

    process_temp_data(expe,subj,num2str(tc));
    
   [gaLn,gaRn] = process_sub_data6(expe,subj,textures_lat,ss,ee,tc,tex_gainsa,randmats{3},show);
     
    if gaLn ~= -1
        gaL = gaL/gaLn
    end
    
    if gaRn ~= -1
        gaR = gaR/gaRn
    end      
    gaL
    gaR
    garLvec(tc) = gaL;
    garRvec(tc) = gaR;
    
%     close all
%     
%     a = figure;
%     a.Position(2) = 400;
%     a.Position(1) = 1250;
%     a.Position(4) = 400;
%     a.Position(3) = 400;
%     plot(garLvec,'.-');
%     plot(garRvec,'.-');
    
    pause(.01);
end

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_trial_3','proxim_mat','randmat_3','randmats');
%% experiment 7 - move stage to the ready

move_stage(port,-3500,1);
while enc_val<(-3500)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.01);
end

%% experiment 7 - move stage back

move_stage(port,-30000,1);
while enc_val<(-30000)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.01);
end

%% expriment 7 - identify which texture is closest real vs real

create_rand_comp();

proxim_mat_4 = 2*ones(7,7);
tex_trial_4 = zeros(7,7);
expp = exp6;
expe = '7';
sig = zeros(dur*sr,1);
% clear buffer

if get(port,'BytesAvailable')>0
    v = fscanf(port);
end
fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);
if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end
clear ch1 ch2 ch3 ch4 ch5 ch6 st lh
ch_init();

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_trial_4','proxim_mat_4','randmats');

show = 0;

for tc = 1:21
    
    expp.tex.Text = strcat('Presenting Texture Combination '," ",strcat(num2str(tc)),'/21');   
    
    randmat_4(tc,3)
    
    while expp.next == 0
        
        while expp.again == 0
            pause(.01);
        end
       
        if expp.next == 0            
           
            delete('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\data_temp.mat');
            
            lh = addlistener(st,'DataAvailable', @saveDAQdata);
                
            release(st)
            queueOutputData(st,sig);
            st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
            st.startBackground();
            
            move_stage(port,86500,1);
            while enc_val<(86500)
                fprintf(port,'p');
                v = fscanf(port);
                v = fscanf(port);
                enc_val = str2num(v);
                pause(.01);
            end
            
            fprintf(port,'1');
            v = fscanf(port);
            move_trib(port,1100);
            pause(2);
                        
            move_stage(port,(9500),1);
            while enc_val>(9500)
                fprintf(port,'p');
                v = fscanf(port);
                v = fscanf(port);
                enc_val = str2num(v);
                pause(.01);
            end
            
            fprintf(port,'1');
            v = fscanf(port);
            move_trib(port,0);
            
            pause(2);
                        
            expp.again = 0;
            expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
            expp.PresstoSwipeButton.Text = 'Press to Swipe';   
            
            pause(.01)
            
            tex_trial_4(randmat_4(tc,1),randmat_4(tc,2)) = tex_trial_4(randmat_4(tc,1),randmat_4(tc,2)) + 1;
        end
    end
    
    proxim_mat_4(randmat_4(tc,1),randmat_4(tc,2)) = expp.answer;
    
    move_stage(port,-30000,1);
    while enc_val<(-30000)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);
    end
    
    while length(dir(dirr)) == 2
        pause(.01);
    end
    
    stat = 0;
    t = timer('TimerFcn', 'stat=true;' ,'StartDelay',2);
    start(t)

    while stat == 0
        pause(.01)
    end
       
    if mod(tc,10) == 0
        clear ch1 ch2 ch3 ch4 ch5 ch6 st lh
        ch_init();
    end
    
    ready = 0;
    
    fprintf(port,'a');
    v = fscanf(port);
    
    while ready == 0
        fprintf(port,'b');
        v = fscanf(port);
        v = fscanf(port);
        ready = str2num(v);
        pause(.01);
    end
    
    fprintf(port,'a');
    v = fscanf(port);
    
    move_stage(port,-3500,1);
    while enc_val<(-3500)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);
    end


    expp.next = 0;
    expp.again = 0;
    expp.FinishedAnsweringButton.BackgroundColor = [.96 .96 .96];
    expp.FinishedAnsweringButton.Text = 'Finished Adjusting';
    expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
    expp.PresstoSwipeButton.Text = 'Swipe Again';
    
    expp.RIGHTcomes1stButton.BackgroundColor = [.96 .96 .96];
    expp.LEFTcomes2ndButton.BackgroundColor = [.96 .96 .96];
    expp.answer = 2;

    process_temp_data(expe,subj,num2str(tc));
    
end

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_trial_4','proxim_mat_4','randmats');

%% experiment 4 - load original textures & get ready for experiment start

move_stage(port,-30000,1);
while enc_val<(-30000)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.01);
end

%% experiment 4 - real vs real texture comparison
           
% init 

expp = exp4;
expe = '4';

sim_mat_1 = zeros(7,7);
tex_trial_1 = zeros(7,7);
trial = 1;

create_rand_comp();

% clear buffer

if get(port,'BytesAvailable')>0
    v = fscanf(port);
end

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);

if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

clear ch1 ch2 ch3 ch4 ch5 ch6 st lh
ch_init();

for tc = 1:21    
    
    expp.tex.Text = strcat('Presenting Texture Combination '," ",strcat(num2str(tc)),'/21');   
    
    while expp.next == 0
        
        while expp.again == 0
            pause(.01);
        end
        
        if expp.next == 0            
           
            delete('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\data_temp.mat');
            lh = addlistener(st,'DataAvailable', @saveDAQdata);
            sig = -5*ones(sr*dur,1);
            sig(end) = 0;
            sig(sig>5) = 5;
            sig(sig<-5) = -5;
            release(st)
            queueOutputData(st,sig);
            st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
            st.startBackground();
            
            move_stage(port,90000,1);
            while enc_val<90000
                fprintf(port,'p');
                v = fscanf(port);
                v = fscanf(port);
                enc_val = str2num(v);
                pause(.01);
            end
            
            fprintf(port,'1');
            v = fscanf(port);
            move_trib(port,1100);
             pause(2);            
           
            
            move_stage(port,(7000),1);
            while enc_val>(7000)
                fprintf(port,'p');
                v = fscanf(port);
                v = fscanf(port);
                enc_val = str2num(v);
                pause(.01);
            end
            
            fprintf(port,'1');
            v = fscanf(port);
            move_trib(port,0);
            
            expp.again = 0;
            expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
            expp.PresstoSwipeButton.Text = 'Press to Swipe';
            
            tex_trial_1(randmat_1(tc,1),randmat_1(tc,2)) = tex_trial_1(randmat_1(tc,1),randmat_1(tc,2)) + 1;
                
        end
    end
    
    sim_mat_1(randmat_1(tc,1),randmat_1(tc,2)) = expp.similarity
    
    while length(dir(dirr)) == 2
        pause(.01);
    end
    
    stat = 0;
    t = timer('TimerFcn', 'stat=true;' ,'StartDelay',2);
    start(t)
    
    move_stage(port,(-30000),1);
    while enc_val>(-30000)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);
    end
   
    while stat == 0        
        pause(.01)
    end
            
    if mod(tc,10) == 0
        clear ch1 ch2 ch3 ch4 ch5 ch6 st lh
        ch_init();
    end
    
    ready = 0;
    
    while ready == 0
        fprintf(port,'b');
        v = fscanf(port);
        v = fscanf(port);
        ready = str2num(v);
        pause(.01);
    end
    
    fprintf(port,'a');
    v = fscanf(port);
    
    expp.next = 0;
    expp.again = 0;
    expp.FinishedAdjustingButton.BackgroundColor = [.96 .96 .96];
    expp.FinishedAdjustingButton.Text = 'Finished Adjusting';
    expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
    expp.PresstoSwipeButton.Text = 'Swipe Again';
    
    expp.SIMSlider.Value = 0;
    expp.similarity = -1;

    process_temp_data(expe,subj,num2str(trial));
    trial = trial + 1;    

end

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_trial_1','sim_mat_1');
%load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'));

%% experiment 5 - load original textures & get ready for experiment start

move_stage(port,-7000,1);
while enc_val<(-7000)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.01);
end

%% experiment 5 - compare real and virtual

% init

sim_mat_2 = zeros(8,7);
tex_trial_2 = zeros(8,7);
trial = 1;

expp = exp5;
expe = '5';

% clear buffer

if get(port,'BytesAvailable')>0
    v = fscanf(port);
end

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);

if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

clear ch1 ch2 ch3 ch4 ch5 ch6 st lh
ch_init();

for tc = 1:56    
    
    expp.tex.Text = strcat('Presenting Texture Combination '," ",strcat(num2str(tc)),'/56');   
    
    while expp.next == 0
        
        while expp.again == 0
            pause(.01);
        end
       
        if expp.next == 0            
           
            delete('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\data_temp.mat');
            
            lh = addlistener(st,'DataAvailable', @saveDAQdata);
            if randmat_2(tc,1) == 8
                sig = zeros(sr*dur,1);
            else
                sig = (2^tex_gains{randmat_2(tc,1)}(end))*textures_processed{randmat_2(tc,1)}.';
            end
            sig(end) = 0;
            sig(sig>5) = 5;
            sig(sig<-5) = -5;
            release(st)
            queueOutputData(st,sig);
            st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
            st.startBackground();
            
            move_stage(port,90000,1);
            while enc_val<(90000)
                fprintf(port,'p');
                v = fscanf(port);
                v = fscanf(port);
                enc_val = str2num(v);
                pause(.01);
            end
            
            fprintf(port,'1');
            v = fscanf(port);
            move_trib(port,1100);
            pause(2);
                        
            move_stage(port,(7000),1);
            while enc_val>(7000)
                fprintf(port,'p');
                v = fscanf(port);
                v = fscanf(port);
                enc_val = str2num(v);
                pause(.01);
            end
            
            fprintf(port,'1');
            v = fscanf(port);
            move_trib(port,0);
            
            pause(2);
                        
            expp.again = 0;
            expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
            expp.PresstoSwipeButton.Text = 'Press to Swipe';   
            
            pause(.01)
            
            tex_trial_2(randmat_2(tc,1),randmat_2(tc,2)) = tex_trial_2(randmat_2(tc,1),randmat_2(tc,2)) + 1;
        end
    end
    
    sim_mat_2(randmat_2(tc,1),randmat_2(tc,2)) = expp.similarity
    
    while length(dir(dirr)) == 2
        pause(.01);
    end
    
    stat = 0;
    t = timer('TimerFcn', 'stat=true;' ,'StartDelay',2);
    start(t)

    while stat == 0
        pause(.01)
    end
       
    if mod(tc,15) == 0
        clear ch1 ch2 ch3 ch4 ch5 ch6 st lh
        ch_init();
    end
    
    ready = 0;
    
    while ready == 0
        fprintf(port,'b');
        v = fscanf(port);
        v = fscanf(port);
        ready = str2num(v);
        pause(.01);
    end
    
    fprintf(port,'a');
    v = fscanf(port);
    
    expp.next = 0;
    expp.again = 0;
    expp.FinishedAdjustingButton.BackgroundColor = [.96 .96 .96];
    expp.FinishedAdjustingButton.Text = 'Finished Adjusting';
    expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
    expp.PresstoSwipeButton.Text = 'Swipe Again';
    
    expp.SIMSlider.Value = 0;
    expp.similarity = -1;

    process_temp_data(expe,subj,num2str(trial));
    
    trial = trial + 1;        
end

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_trial_2','sim_mat_2');