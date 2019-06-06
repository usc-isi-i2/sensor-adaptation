function value = get_data_field(obj)

value = zeros(23,1);

value(1) = process_text(obj.tempm);
value(2) = process_text(obj.tempi);
value(3) = process_text(obj.dewptm);
value(4) = process_text(obj.dewpti);
value(5) = process_text(obj.hum);
value(6) = process_text(obj.wspdm);
value(7) = process_text(obj.wspdi);
value(8) = process_text(obj.wgustm);
value(9) = process_text(obj.wgusti);
value(10) = process_text(obj.wdird);

switch obj.wdire(1)
    case 'S'
        value(11) = 1;
    case 'N'
        value(11) = 2;
    case 'E'
        value(11) = 3;
    case 'W'
        value(11) = 4;
end

value(12) = process_text(obj.pressurem);
value(13) = process_text(obj.pressurei);
value(14) = process_text(obj.windchillm);
value(15) = process_text(obj.windchilli);
value(16) = process_text(obj.heatindexm);
value(17) = process_text(obj.heatindexi);
value(18) = process_text(obj.precip_ratem);
value(19) = process_text(obj.precip_ratei);
value(20) = process_text(obj.precip_totalm);
value(21) = process_text(obj.precip_totali);
value(22) = process_text(obj.solarradiation);
value(23) = process_text(obj.UV);

function val = process_text(str)

if isempty(str)
    val = -100000;
else
    val = str2num(str);
end
