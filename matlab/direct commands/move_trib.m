function out = move_trib(port,pos)
fprintf(port,'l');
v = fscanf(port);
fprintf(port,num2str(pos));
end