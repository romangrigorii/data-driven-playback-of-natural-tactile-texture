function out = process_temp_data(expe,subj,tria)

load('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\data_temp.mat');
save(strcat('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\data\subject data\',subj,'\',expe,'_',tria,'.mat'),'dataQ')

end