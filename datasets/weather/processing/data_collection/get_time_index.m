function index = get_time_index(date)

index = str2num(date.hour)*60 + str2num(date.min);