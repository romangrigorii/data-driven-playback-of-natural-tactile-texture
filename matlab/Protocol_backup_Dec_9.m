addpath(genpath('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture'));
addpath(genpath('C:\Users\atrox\Desktop\Work\Research\Code'));

%% init PIC and DAQ
clear all

dirr = 'C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\';

subj = 'x4';
if ~isempty(instrfind)
    fclose(instrfind);
end

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

dur = 8.5;
sr = 46500;
st = daq.createSession('ni');
st.Rate = sr;
st.DurationInSeconds = dur;
ch1 = addAnalogInputChannel(st,'Dev2','ai1','Voltage');
ch1.InputType = 'SingleEnded'; %% lateral force
ch2 = addAnalogInputChannel(st,'Dev2','ai9','Voltage');
ch2.InputType = 'SingleEnded'; %% normal force
ch3 = addAnalogInputChannel(st,'Dev2','ai10','Voltage');
ch3.InputType = 'SingleEnded'; %% LDV
ch4 = addAnalogInputChannel(st,'Dev2','ai3','Voltage');
ch4.InputType = 'SingleEnded'; %% current
ch5 = addCounterInputChannel(st, 'Dev2', 0, 'Position');
ch5.EncoderType = 'X4';
ch6 = addAnalogOutputChannel(st,'Dev2','ao0','Voltage');
lh = addlistener(st,'DataAvailable', @saveDAQdata);

%% adjusting normal load

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);

enc_val = 0;
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
move_trib(port,900);
pause(3);

x = input('press enter when normal load is at desired range\n');

fprintf(port,'1');
v = fscanf(port);
move_trib(port,0);
pause(3);

move_stage(port,(4500),1);
while enc_val>(4500)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.1);
end


%% experiment 1 - capture

freqs = logspace(log10(20),log10(1000),7);
freqsi = randperm(7);
expp = exp1;
expe = '1';
PP = [];
textures = {};

for t = 1:length(freqs)

    while (expp.enter == 0)
        pause(.1);
    end
    
    if freqs(freqsi(t)) == 1000
        sig = 0*sin(2*pi*freqs(freqsi(t))*linspace(0,dur,sr*dur));
    else
        sig = 1.5*sin(2*pi*freqs(freqsi(t))*linspace(0,dur,sr*dur));
    end
    
    sig(end) = 0;
    removeChannel(st,6);
    ch6 = addAnalogOutputChannel(st,'Dev2','ao0','Voltage');
    lh = addlistener(st,'DataAvailable', @saveDAQdata);
    queueOutputData(st,sig.');
    st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
    st.startBackground();
    
    enc_val = 0;
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
    move_trib(port,900);
    pause(2);
    
    move_stage(port,(4500),1);
    
    while enc_val>(4500)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);
    end
    
    fprintf(port,'1');
    v = fscanf(port);
    move_trib(port,0);
    
    ready = 0;
    while ready == 0
        fprintf(port,'b');
        v = fscanf(port);
        v = fscanf(port);
        ready = str2num(v);
        pause(.1);
    end
    
    process_temp_data(expe,subj,num2str(t));
    
    fprintf(port,'a');
    v = fscanf(port);
    
    expp.ready = 1;
    expp.enter = 0;
    expp.PresswhenreadyButton.BackgroundColor = [.96 .96 .96];
    expp.PresswhenreadyButton.Text = 'Press when ready';    
    t
end

[textures,texturesp,textures_processed,ss,ee] = process_sub_data1(expe,subj);
save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'freqs','freqsi','sr','dur');

%% experiment 2 - volume play
expp = exp2;
gains = [1,1.5,2,3];
expe = '2';
tn = 1;

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);
if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

for g = 1:length(gains)

    
    expp.gain = gains(g);
    expp.EditField.Value = gains(g);
    
    while (expp.again == 0)
        pause(.1);
    end
    
    close all
    
    removeChannel(st,6);
    ch6 = addAnalogOutputChannel(st,'Dev2','ao0','Voltage');
    lh = addlistener(st,'DataAvailable', @saveDAQdata);
    sig = gains(g)*textures_processed{tn}.';
    sig(end) = 0;
    sig(sig>5) = 5;
    sig(sig<-5) = -5;
    release(st)
    queueOutputData(st,sig);
    st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
    st.startBackground();        
    
    enc_val = 0;
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
    move_trib(port,900);
    pause(2);
    
    move_stage(port,(4500),1);
    
    while enc_val>(4500)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);   
    end
    
    fprintf(port,'1');
    v = fscanf(port);
    move_trib(port,0);
    
    ready = 0;
    while ready == 0
        fprintf(port,'b');
        v = fscanf(port);
        v = fscanf(port);
        ready = str2num(v);
        pause(.1);
    end
    
    process_temp_data(expe,subj,num2str(g));
    
    process_sub_data2(expe,subj,textures{tn},ss,ee,num2str(g),gains(g));
    
    fprintf(port,'a');
    v = fscanf(port);
    
    expp.again = 0;
    expp.SwipeagainButton.BackgroundColor = [.96 .96 .96];
    expp.SwipeagainButton.Text = 'Swipe again';       
   
end

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur');

%% experiment 3 - volume adjust
expp = exp3;
tex_trial_1 = zeros(1,7);
tex_gains = {};
trial = 1;
expe = '3';

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);
if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

rdy = 0;

for t = 1:7
    tex_gains{t} = [];
    
    expp.tex.Text = strcat('Presenting Texture '," ",num2str(t));
    
    while expp.next == 0
        
        while expp.again == 0
            pause(.1);
        end
        
        if expp.next == 0
            
            tex_gains{t} = [tex_gains{t},expp.gain];
            
            removeChannel(st,6);
            ch6 = addAnalogOutputChannel(st,'Dev2','ao0','Voltage');
            lh = addlistener(st,'DataAvailable', @saveDAQdata);
            sig = expp.gain*textures_processed{t}.';
            sig(end) = 0;
            sig(sig>5) = 5;
            sig(sig<-5) = -5;
            release(st)
            queueOutputData(st,sig);
            st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
            st.startBackground();
            
            enc_val = 0;
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
            move_trib(port,900);
            pause(2);
            
            move_stage(port,(4500),1);
            while enc_val>(4500)
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
                pause(.1);
            end
            
            pause(2);
            
            process_temp_data(expe,subj,num2str(trial));
            
            process_sub_data3(expe,subj,textures{t},ss,ee,num2str(trial),expp.gain);
            
            trial = trial + 1;
            
            tex_trial_1(t) = tex_trial_1(t)+1;
            
            expp.again = 0;
            expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
            expp.PresstoSwipeButton.Text = 'Press to Swipe';
        end        
    end       
   
    ready = 0;
    
    while ready == 0
        fprintf(port,'b');
        v = fscanf(port);
        v = fscanf(port);
        ready = str2num(v);
        pause(.1);
    end
    
    expp.next = 0;
    expp.again = 0;
    expp.FinishedAdjustingButton.BackgroundColor = [.96 .96 .96];
    expp.FinishedAdjustingButton.Text = 'Finished Adjusting';
    expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
    expp.PresstoSwipeButton.Text = 'Swipe Again';
    
    fprintf(port,'a');
    v = fscanf(port);
    
    expp.gain = 1;
    expp.GAINSlider.Value = 1;
    
end

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_gain','tex_trial');

%% experiment 4 - load original textures & get ready for experiment start

expp = exp4;
expe = '4';

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);
if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

ready = 0;
while ready == 0
    fprintf(port,'b');
    v = fscanf(port);
    v = fscanf(port);
    ready = str2num(v);
    pause(.1);
end

fprintf(port,'a');
v = fscanf(port);

expp.SLIDINGLEFTLabel.Visible = 1;
pause(1)

fprintf(port,'1');
v = fscanf(port);
move_trib(port,-200);

enc_val = 0;
move_stage(port,-37000,1);
while enc_val<(-37000)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.01);
end

ready = 0;
while ready == 0
    fprintf(port,'b');
    v = fscanf(port);
    v = fscanf(port);
    ready = str2num(v);
    pause(.1);
end

fprintf(port,'a');
v = fscanf(port);

expp.SLIDINGLEFTLabel.Text = 'SLIDING RIGHT';
pause(1)

fprintf(port,'1');
v = fscanf(port);
move_trib(port,0);

move_stage(port,(-4500),1);
while enc_val>(-4500)
    fprintf(port,'p');
    v = fscanf(port);
    v = fscanf(port);
    enc_val = str2num(v);
    pause(.01);
end

expp.SLIDINGLEFTLabel.Visible = 0;
expp.SLIDINGLEFTLabel.Text = 'SLIDING LEFT';

expp.next = 0;
expp.again = 0;
expp.FinishedAdjustingButton.BackgroundColor = [.96 .96 .96];
expp.FinishedAdjustingButton.Text = 'Finished Adjusting';
expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
expp.PresstoSwipeButton.Text = 'Swipe Again';

expp.similarity = 0;
expp.SIMSlider.Value = 0;



%% experiment 4 - real vs real texture comparison

tex_comps = [6,5,4,3,2,1];

tsf = 1;
sim_mat_1 = zeros(7,7);
tex_trial_1 = zeros(7,7);
trial = 1;

for t1 = 1:length(tex_comps)     
    for t2 = 1:tex_comps(t1)
        
        expp.tex.Text = strcat('Presenting Texture Combination '," ",strcat(num2str(tsf)),'/21');
        
        while expp.next == 0
            
            while expp.again == 0
                pause(.1);
            end
            
            sim_mat_1(t1,t2) = expp.similarity;
            
            if expp.next == 0
                
                delete('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\dat_temp.mat');
                removeChannel(st,6);
                ch6 = addAnalogOutputChannel(st,'Dev2','ao0','Voltage');
                lh = addlistener(st,'DataAvailable', @saveDAQdata);
                sig = zeros(dur*sr,1);
                sig(end) = 0;
                sig(sig>5) = 5;
                sig(sig<-5) = -5;
                release(st)
                queueOutputData(st,sig);
                st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
                st.startBackground();
                
                enc_val = 0;
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
                move_trib(port,900);
                pause(2);
                
                move_stage(port,(4500),1);
                while enc_val>(4500)
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
                
                pause(2);
                
                process_temp_data(expe,subj,num2str(trial));
                
                trial = trial + 1;
                
                tex_trial_1(t1,t2) = tex_trial_1(t1,t2) + 1;
                
                expp.again = 0;
                expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
                expp.PresstoSwipeButton.Text = 'Press to Swipe';
            end
        end
        
        if t2 < tex_comps(t1)
            ready = 0;
            
            while ready == 0
                fprintf(port,'b');
                v = fscanf(port);
                v = fscanf(port);
                ready = str2num(v);
                pause(.1);
            end
            
            fprintf(port,'a');
            v = fscanf(port);
            
            expp.next = 0;
            expp.again = 0;
            expp.FinishedAdjustingButton.BackgroundColor = [.96 .96 .96];
            expp.FinishedAdjustingButton.Text = 'Finished Adjusting';
            expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
            expp.PresstoSwipeButton.Text = 'Swipe Again';
            
            expp.similarity = 0;
            expp.SIMSlider.Value = 0;
        end
        
        tsf = tsf + 1;
    end
    
    expp.SLIDINGLEFTLabel.Visible = 1;
    pause(1)
    
    fprintf(port,'1');
    v = fscanf(port);
    move_trib(port,-200);
                
    enc_val = 0;
    move_stage(port,-37000,1);
    while enc_val<(-37000)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);
    end
                
    ready = 0;
    while ready == 0
        fprintf(port,'b');
        v = fscanf(port);
        v = fscanf(port);
        ready = str2num(v);
        pause(.1);
    end
    
    fprintf(port,'a');
    v = fscanf(port);
    
    expp.SLIDINGLEFTLabel.Text = 'SLIDING RIGHT';
    pause(1)
       
    move_stage(port,(-3000),1);
    while enc_val>(-3000)
        fprintf(port,'p');
        v = fscanf(port);
        v = fscanf(port);
        enc_val = str2num(v);
        pause(.01);
    end    
    
    fprintf(port,'1');
    v = fscanf(port);
    move_trib(port,0);
   
    expp.SLIDINGLEFTLabel.Visible = 0;
    expp.SLIDINGLEFTLabel.Text = 'SLIDING LEFT';
    
    expp.next = 0;
    expp.again = 0;
    expp.FinishedAdjustingButton.BackgroundColor = [.96 .96 .96];
    expp.FinishedAdjustingButton.Text = 'Finished Adjusting';
    expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
    expp.PresstoSwipeButton.Text = 'Swipe Again';    
   
    expp.similarity = 0;
    expp.SIMSlider.Value = 0;
    
end

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_gain','tex_trial','sim_mat');
%load(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'));
%% 

sim_mat_2 = zeros(8,7);
tex_trial_2 = zeros(8,7);
tsf = 0;
trial = 0;

expp = exp5;
expe = '5';

fprintf(port,'b');
v = fscanf(port);
v = fscanf(port);
if v == 1
    fprintf(port,'a');
    v = fscanf(port);
end

for t2 = 1:7  
    for t1 = 1:8   
        expp.tex.Text = strcat('Presenting Texture Combination '," ",strcat(num2str(tsf)),'/56');
        
        while expp.next == 0
            
            while expp.again == 0
                pause(.1);
            end
            
            sim_mat_2(t1,t2) = expp.similarity;
            
            if expp.next == 0
                
                process_temp_data(expe,subj,num2str(trial));
                
                delete('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\dat_temp.mat');
                removeChannel(st,6);
                ch6 = addAnalogOutputChannel(st,'Dev2','ao0','Voltage');
                lh = addlistener(st,'DataAvailable', @saveDAQdata);
                if t1 == 8
                    sig = zeros(dur*sr,1);
                else
                    sig = tex_gains{t1}(end)*textures_processed{t1}.';
                end
                sig(end) = 0;
                sig(sig>5) = 5;
                sig(sig<-5) = -5;
                release(st)
                queueOutputData(st,sig);
                st.NotifyWhenDataAvailableExceeds = int32(sr*dur);
                st.startBackground();
                
                enc_val = 0;
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
                move_trib(port,900);
                pause(2);
                
                move_stage(port,(4500),1);
                while enc_val>(4500)
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
                
                pause(1);        
                
                trial = trial + 1;
                
                tex_trial_2(t1,t2) = tex_trial_2(t1,t2) + 1;
                
                expp.again = 0;
                expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
                expp.PresstoSwipeButton.Text = 'Press to Swipe';
            end
        end
        
        ready = 0;
        
        while ready == 0
            fprintf(port,'b');
            v = fscanf(port);
            v = fscanf(port);
            ready = str2num(v);
            pause(.1);
        end
        
        fprintf(port,'a');
        v = fscanf(port);
        
        expp.next = 0;
        expp.again = 0;
        expp.FinishedAdjustingButton.BackgroundColor = [.96 .96 .96];
        expp.FinishedAdjustingButton.Text = 'Finished Adjusting';
        expp.PresstoSwipeButton.BackgroundColor = [.96 .96 .96];
        expp.PresstoSwipeButton.Text = 'Swipe Again';
        
        expp.similarity = 0;
        expp.SIMSlider.Value = 0;
         
        tsf = tsf + 1;
    end   
end

save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_x.mat'),'sr','dur','tex_gain','tex_trial','sim_mat');