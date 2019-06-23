function [res_replace, res_ref_neu, res_reffx] = res_cali(res_replace, res_ref_neu, res_reffx, res_refer)

res_replace = [res_refer.avg(:,1), res_refer.std(:,1)];
res_ref_neu = [res_refer.avg(:,2), res_refer.std(:,2)];
res_reffx = [res_refer.avg(:,3), res_refer.std(:,3)];