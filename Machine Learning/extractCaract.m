%Funció que et permeti extreure les carecteristiques per ordre d'importancia. 
function [idx,weights] = extractCaract(X,y,k, nG)

[idx,weights] = relieff(X,y,k) %Calcula rangs i pesos de 
% atributs (predictors) per a la matriu de dades d'entrada X i el vector de resposta Y 
% utilitzant l'algorisme ReliefF per a la classificació o RReliefF per a la regressió 
% amb K veïns més propers. Per a la classificació, relieff utilitza K 
% de veïns més propers per classe. Si Y és numèric, relieff per defecte realitza anàlisis RReliefF per a
% regressió. Si Y és categòric, lògic, una matriu de caràcters o una cel·la 
% matriu de cadenes% de , relieff per defecte realitza l'anàlisi ReliefF per a la 
% classificació. 
pos = weights >= 0;
carbonpredict = sum(pos);

if  nG==1
    %Create a bar plot of predictor importance weights.
    bar(weights(idx))
    text(carbonpredict,0.025,sprintf('%d',carbonpredict))
    xlabel('Predictor rank')
    ylabel('Predictor importance weight')
    title('Relieff per NG1');
elseif  nG==2
    bar(weights(idx))
    text(carbonpredict,0.025,sprintf('%d',carbonpredict))
    xlabel('Predictor rank')
    ylabel('Predictor importance weight')
    title('Relieff per NG2');
elseif  nG==3
    bar(weights(idx))
    text(carbonpredict,0.025,sprintf('%d',carbonpredict))
    xlabel('Predictor rank')
    ylabel('Predictor importance weight')
    title('Relieff per NG3');
elseif  nG==4
    bar(weights(idx))
    text(carbonpredict,0.025,sprintf('%d',carbonpredict))
    xlabel('Predictor rank')
    ylabel('Predictor importance weight')
    title('Relieff per NG4');
elseif  nG==5
    bar(weights(idx))
    text(carbonpredict,0.025,sprintf('%d',carbonpredict))
    xlabel('Predictor rank')
    ylabel('Predictor importance weight')
    title('Relieff per NG5');
end

end

