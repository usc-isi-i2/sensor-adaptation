function [precision, recall] = prec_recall(ground_truth, detect_label)

% precision recall
tp = 0;
fp = 0;
tn = 0;
fn = 0;

for i = 1:length(ground_truth)
   if  ground_truth(i) == 1 && detect_label(i) == 1
       tp = tp + 1;
   elseif ground_truth(i) == 0 && detect_label(i) == 0
       tn = tn + 1;
   elseif ground_truth(i) == 1 && detect_label(i) == 0
       fn = fn + 1;
   else
       fp = fp +1;
   end
end

precision = tp/(tp+fp);
recall = tp/(tp+fn);