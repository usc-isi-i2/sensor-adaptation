function get_data_fun(pws_str, key_set, year_str, sta_month, end_month)

n_day = [31,28,31,30,31,30,31,31,30,31,30,31];

key_id = 1;
n_time_pause = 5/length(key_set);

for i = sta_month:end_month
    cc = 0;
    
    for j = 1:n_day(i)
        
        date_str = year_str;
        
        % month
        if i < 10
            date_str = [date_str,'0',num2str(i)];
        else
            date_str = [date_str,num2str(i)];
        end
        
        month_year_str = date_str;
        
        % day
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
        
        try
            str = urlread(url);
        catch ex
            sleep(2);
            str = urlread(url);
        end
        
        cc = cc + 1;
        disp([pws_str, ' - ', date_str]);
        
        data{cc} = JSON.parse(str);
        date_info{cc} = date_str;
        
        pause(n_time_pause);
    end
    
    fname = ['PWS_',pws_str,'_',month_year_str,'.mat'];
    save(['dataset/', fname],'data','date_info');
    
    process_data(fname);
end