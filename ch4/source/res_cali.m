function [res_replace, res_refer, res_referZ, res_asc] = res_cali(res_replace, res_refer, res_referZ, res_asc, res_refer2)

res_replace = [res_refer2.avg(:,1), res_refer2.std(:,1)];
res_refer = [res_refer2.avg(:,2), res_refer2.std(:,2)];
res_referZ = [res_refer2.avg(:,3), res_refer2.std(:,3)];
res_asc = [res_refer2.avg(:,4), res_refer2.std(:,4)];