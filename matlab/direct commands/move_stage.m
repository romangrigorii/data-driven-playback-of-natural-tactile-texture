function out = move_stage(port,pos,vel)
fprintf(port,'v');
v = fscanf(port);
fprintf(port,'%s\n',num2str(pos));
fprintf(port,'%s\n',num2str(vel));
v = fscanf(port);
end