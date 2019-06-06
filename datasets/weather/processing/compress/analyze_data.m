function analyze_data(pws)

field_set{1} = 'tempm';
field_set{2} = 'tempi';
field_set{3} = 'dewptm';
field_set{4} = 'dewpti';
field_set{5} = 'hum';
field_set{6} = 'wspdm';
field_set{7} = 'wspdi';
field_set{8} = 'wgustm';
field_set{9} = 'wgusti';
field_set{10} = 'wdird';
field_set{11} = 'wdire';
field_set{12} = 'pressurem';
field_set{13} = 'pressurei';
field_set{14} = 'windchillm';
field_set{15} = 'windchilli';
field_set{16} = 'heatindexm';
field_set{17} = 'heatindexi';
field_set{18} = 'precip_ratem';
field_set{19} = 'precip_ratei';
field_set{20} = 'precip_totalm';
field_set{21} = 'precip_totali';
field_set{22} = 'solarradiation';
field_set{23} = 'uv';

n_observ_all = [];
gap_all = [];

count = zeros(1,23);

for m = 1:12
    if m == 1
        fname = ['PWS_', pws, '_201601.mat_comp.mat'];
    elseif m < 10
        fname = ['PWS_', pws, '_20150',num2str(m),'.mat_comp.mat'];
    else
        fname = ['PWS_', pws, '_2015',num2str(m),'.mat_comp.mat'];
    end
    
    load(fname,'fea');
    
    % n_of_observation_per_day
    t = fea(24,:);
    
    for i = 1:max(t)
        n_observ(i) = sum( t==i );
    end
    
    n_observ_all = [n_observ_all, n_observ];
    
    cc = 0;
    for i = 1:max(t)
        idx = find( t==i );
        
        for j = 2:length(idx)
            cc = cc + 1;
            gap(cc) = fea(25,idx(j)) - fea(25,idx(j-1));
        end
    end
    gap_all = [gap_all, gap];
    
    % check field
    if m == 3
        if sum( fea(1,:) < -900 ) > 0
            fprintf('Temperature, ');
        end
        if sum( fea(3,:) < -900 ) > 0
            fprintf('Dew point, ');
        end
        if sum( fea(5,:) < -900 ) > 0
            fprintf('Humidity, ');
        end
        if sum( fea(10,:) < -900 ) > 0
            fprintf('Wind Direction, ');
        end
        if sum( fea(6,:) < -900 ) > 0
            fprintf('Wind Speed, ');
        end
        if sum( fea(8,:) < -900 ) > 0
            fprintf('Wind Speed Gust, ');
        end
        if sum( fea(12,:) < -900 ) > 0
            fprintf('pressure, ');
        end
        if sum( fea(18,:) < -900 ) > 0
            fprintf('precip. rate, ');
        end
        if sum( fea(20,:) < -900 ) > 0
            fprintf('precip. accum., ');
        end
        if sum( fea(23,:) < -900 ) > 0
            fprintf('UV index, ');
        end
        if sum( fea(22,:) < -900 ) > 0
            fprintf('SolarRadiationWatts, ');
        end
        if sum( fea(14,:) < -900 ) > 0
            fprintf('Wind Chill, ');
        end
        if sum( fea(16,:) < -900 ) > 0
            fprintf('Heat Index, ');
        end
        fprintf('\n');
    end
    
end
keyboard