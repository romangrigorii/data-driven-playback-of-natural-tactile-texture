function saveDAQdata(src,event)   
    dataQ = event.Data;
    save('C:\Users\atrox\Desktop\Work\Research\My projects\Rendering of natural texture\code\matlab\DAQ\data\data_temp.mat','dataQ');
end