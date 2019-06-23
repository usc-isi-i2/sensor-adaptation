function comb = generate_combinations(idx)

cc = 0;
for T = 2:4
    comb_T = combnk(idx,T);
    
    if isempty(comb_T)
        return;
    end
    
    for i = 1:size(comb_T,1)
        
        
        pp = perms( comb_T(i,:) );
        
        for j = 1:size(pp,1)
            cc = cc + 1;
            comb{cc} = pp(j,:);
        end
    end
end