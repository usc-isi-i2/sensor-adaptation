function n_obsv = get_data_fun_check(pws_str, key_set, year_str, sta_month, end_month)

n_day = [31,28,31,30,31,30,31,31,30,31,30,31];

key_id = 1;
n_time_pause = 5/length(key_set);

n_obsv = zeros(1,12);

for i = sta_month:end_month

    for j = 1
        
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
        str = urlread(url);
        
        disp([pws_str, ' - ', date_str]);
        
        data{1} = JSON.parse(str);
        
        n_obsv(i) = length(data{1}.history.observations);
        
        pause(n_time_pause);
    end
end