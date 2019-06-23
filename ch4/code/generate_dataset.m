function generate_dataset(id)


switch id
    case 1
        load();
        fname = 'cadata_rmv1';
    case 2
        fname = 'cadata_rmv7';
    case 3
        fname = 'cadata_rmv1_7';
    case 4
        fname = 'prototask_rmv11';
    case 5
        fname = 'prototask_rmv9';
    case 6
        fname = 'prototask_rmv11_9';
    case 7
        fname = 'prototask_rmv11_10';
    case 8
        fname = 'weather_1_side2';
    case 9
        fname = 'weather_4_side5';
    case 10
        fname = 'weather_5_side4';
    case 11
        fname = 'weather_6_side6';
    case 12
        fname = 'weather_5_side5';
    case 13
        fname = 'weather_4_side4';
    case 14
        fname = 'weather_3_side3';
    case 15
        fname = 'weather_1_side1';
end