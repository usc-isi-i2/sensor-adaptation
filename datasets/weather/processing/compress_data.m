function compress_data(pws)

month_set = cell(1,12);
month_set{1} = '201601';
month_set{2} = '201502';
month_set{3} = '201503';
month_set{4} = '201504';
month_set{5} = '201505';
month_set{6} = '201506';
month_set{7} = '201507';
month_set{8} = '201508';
month_set{9} = '201509';
month_set{10} = '201510';
month_set{11} = '201511';
month_set{12} = '201512';

for i = 1:12
    process_data(['PWS_',pws,'_', month_set{i},'.mat']);
end