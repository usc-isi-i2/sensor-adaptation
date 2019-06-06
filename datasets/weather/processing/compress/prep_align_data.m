station_name = 'PWS_KCAPASAD31';

load([station_name, '_201505.mat_comp.mat']);

sel_idx = [1,3,5,6,8];

len = length(dates);
feaA = fea(sel_idx,:);
timeA = cell(1,len);
for i = 1:len
    t = dates{i};
    timeA{i} = [t.year,t.mon,t.mday,' ',t.hour,':',t.min];
end

load([station_name, '_201506.mat_comp.mat']);

len = length(dates);
feaA = [feaA,fea(sel_idx,:)];
timeA_add = cell(1,len);
for i = 1:len
    t = dates{i};
    timeA_add{i} = [t.year,t.mon,t.mday,' ',t.hour,':',t.min];
end
timeA = [timeA, timeA_add];


fileID = fopen('station_B.txt', 'w');
for i = 1:length(timeA)
    
    if mod(i,1000) == 1
        fprintf('%d\n',i);
    end
    
    fprintf(fileID, '%s\t', timeA{i});
    for j = 1:5
        fprintf(fileID, '%s\t', num2str(feaA(j,i)) );
    end
    fprintf(fileID,'\n');
end
fclose(fileID);
