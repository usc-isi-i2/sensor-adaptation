function get_data_fun_backup(pws_str, key_set)

n_day = [31,28,31,30,31,30,31,31,30,31,30,31];

key_id = 1;
n_time_pause = 5/length(key_set);

% Jan is from 2016, other months from 2015
for i = 
    cc = 0;
    
    for j = 1:n_day(i)
        
        if i == 1
            date_str = ['2016'];
        else
            date_str = ['2015'];
        end
        
        % month
        if i < 10
            date_str = [date_str,'0',num2str(i)];
        else
            date_str = [date_str,num2str(i)];
        end
        
        % year
        if j < 10
            date_str = [date_str,'0',num2str(j)];
        else
            date_str = [date_str,num2str(j)];
        end
        
        key_str = key_set{key_id};
        
        key_id = key_id + 1;
        if key_id > length(key_set)
            key_id = 1;
        end
        
        url = ['http://api.wunderground.com/api/',key_str,'/history_',date_str,'/q/pws:',pws_str,'.json'];
        str = urlread(url);
        
        cc = cc + 1;
        disp([pws_str, ' - ', date_str]);
        
        data{cc} = JSON.parse(str);
        date_info{cc} = date_str;
        
        pause(n_time_pause);   
    end
    
    if i == 1
        month_year_str = '201601';
    else
        if i < 10
            month_year_str = ['20150',num2str(i)];
        else
            month_year_str = ['2015',num2str(i)];
        end
    end
    
    fname = ['dataset/PWS_',pws_str,'_',month_year_str,'.mat'];
    save(fname,'data','date_info');
end