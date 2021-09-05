%INPUTS: Li hauràs de passar:
%1 - El model que vols testejar, amb per exemple nM. Que un numero es correspongui a un model.
%Dins posa tots els models que vulguis testejar (4-5
%per començar està be).
%2 - dTrain amb els features que toqui toca segons
%ranks.
%3 - lTrain.
%OUTPUTS: modelo et retornara el model construit que et permet
%testejar. typM el nom del model, que hauras de definir
%tu en la funcio.

% aquesta funcio ha de contenir els diferents models
% que vulguis provar. Proba a buscar com implementar
% KNN (pista: fitcknn), Decision Trees, Random Forest, SVM(pista: fitcsvm), DiscrLin.
% Busca altres models que creguis interessants

function [modelo,typM] = entrenarModelo2(nM,dTrain,lTrain)

if nM==1
    typM= 'SVM';
    modelo = fitcsvm(dTrain,lTrain);

elseif nM==2
    typM='KNN';
    modelo = fitcknn(dTrain,lTrain);
    
elseif nM==3
     typM='Decision Trees';
    modelo = fitctree(dTrain,lTrain);
    
end
