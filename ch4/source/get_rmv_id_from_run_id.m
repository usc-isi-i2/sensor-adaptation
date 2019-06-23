function rmv_id = get_rmv_id_from_run_id(fname, run_id)

% remove useful features

switch fname
    case 'cad8'
        ids = [1,2,8];
    case 'bank8'
        ids = [6,5,7];
    case 'aba10'
        ids = [8];
    case 'cpu11'
        ids = [11,2,5,6,10,8];
    case 'pum8'
        ids = [2,3];
end

rmv_id = ids(run_id);