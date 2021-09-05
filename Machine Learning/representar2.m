function [sensitivity,specificity,accuracy]=representar2(caract,conf)

for m=1:height(conf)

    matrix = conf{m,1};
    num = caract{m};
    confusionchart(matrix(:,:,num))
    title(sprintf('Matriu Confusio per caracteristica %d',num));
    figure;
    
%     tp= matrix(1,1,num);
%     tn= matrix(2,2,num);
%     fn= matrix(1,2,num);
%     fp= matrix(2,1,num);
    tn= matrix(1,1,num);
    tp= matrix(2,2,num);
    fp= matrix(1,2,num);
    fn= matrix(2,1,num);

    sensitivity{m} = tp./(tp + fn);  %TPR
    specificity{m} = tn./(tn + fp);  %TNR
    accuracy{m} = (tp+tn)./(tp+fp+tn+fn);
end
       
end
