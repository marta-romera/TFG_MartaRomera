clear all;
home = cd;
%% Declaracio de variables pels models 
rng(1); % Control per que no sigui random
filename_csv ='TFG_Marta.csv'; % direccio on estigui el CSV
filename_xls ='TFG_Marta.xls'; % direccio on estigui el XLS
NM=3; %Numero de models 
NFS=1; %Numero de filtres
NG=5; % Nivells de gris (16, 23, 64, 128, 256)
particiones=5 ; %Num divisiones en kfold
nRep=1; %Nume de repeticions
k=5; %Parametre en relieff, pel número de veins utiltizats
NumNeighbors=3; % Veins pel modelo knn
posclass=1;% Clase positiva en el modelo predictor (lTrain)
rng(1)
marcador=1;
eval(marcador,:)={'Intento','vectAUC','maxAUC','vect_std','vect_std',...
            'Nivel Gris','Tipo modelo','Tipo Filt o Wrap', 'Numero características','matConfusion','Tiempo'};   
%% Carreguem la tabla csv
T_csv = readtable(filename_csv); %Tractamem el csv como una taula
T_xls = readtable(filename_xls); 
necrosis = [0 1 0 1 0 1 1 1 0 1 0 1 1 1 0 0 0 0 1 0 1 0 1 1 1 0 1 0 1 1 1 0 0 0 0 1 0 1 0 1 1 1 0 1 0 1 1 1 0 0 0];
T_xls.Type = transpose(necrosis);
cabeceras = T_xls.Properties.VariableNames;% Extraiem les capceler en l'arxiu csv

for nG=1:NG
    [label,data,new_cabeceras] = cargar(T_xls,cabeceras,nG); %funcio que li entra la ruta del CSV i el nivell de gris a analitzar
    label=data(:,1);
    data(:,1)=[];
    new_cabeceras(:,1)=[];
    numCaract=size(data,2); %Num total de caracteristiques a analitzar (44 per cada grup T1, T2 y FLAIR)

    for nM=1:NM %Model a utilitzar
        rng(1);
        for nFS=1:NFS %Filtre a utilitzar
            tic %Temps que tarda cada model
            matConfusion=zeros(2,2,numCaract); %Creació matriu de confusio (2x2xnumero de caracteristiques)
            matAUC=zeros(particiones*nRep, numCaract); %Matriu per tots els valors d'AUC
            vectAUC=zeros(1,numCaract); %Mitjana de valors AUC de totes les iteracions
            for rep=1:1 %nRep
                %% Realizem particions
                c=cvpartition(label,'KFold',5); 
                for i=1:particiones %Numero de particions
                    %% Definim matriu de dades i vectors etiquetes o labels
                    dTrain= data(c.training(i),:);
                    lTrain=label(c.training(i),1);
                    dTest= data(c.test(i),:); 
                    lTest=label(c.test(i),1);
                    dTrain = normalize(dTrain); %Normalització caracteristiques segons la seva mitjana i desviacio estandar
                    dTest = normalize(dTest);
                    [ranks(i,:),typFS] = extractCaract(dTrain,lTrain,k,nG);
                    for j=1:numCaract % Num de característiques 
                        %% Extracció de predictors i percentatges
                        features=ranks(1:j);
                        for rank= 1:numel(features)
                            val = ranks(rank);
                            if typFS(rank)>=0
                                concat{rank}= new_cabeceras(val);
                            else concat{rank}=[];
                            end
                        end
                        %% Creació de celes per puntuar les variables 
                        celda_puntuar(nG,nM,nFS,rep,i,j)={features};
                        %% Para los distintos modelos:
                        [modelo,typM] = entrenarModelo2(nM,dTrain(:,features),lTrain);
                        [lPredict,scores]=predict(modelo,dTest(:,features)); %Predicció de l'AUC 
                        [X,Y,~,AUC] = perfcurve(lTest,scores(:,2),posclass);  %Generació AUC 
                        C = confusionmat(lTest,lPredict); %Generació matriu de confusio
                        matConfusion(:,:,j)=matConfusion(:,:,j)+C;
                        matAUC((rep-1)*particiones+i,j)=AUC;

                        if nG==1
                            orden1 = cell2table(concat);writetable(orden1,'ordeng1.csv');
                            orden1= table2cell(orden1); empties1 = find(cellfun(@isempty,orden1)); orden1(empties1) = [];
                        elseif nG==2
                            orden2 = cell2table(concat); writetable(orden2,'ordeng2.csv');
                            orden2= table2cell(orden2); empties2 = find(cellfun(@isempty,orden2)); orden2(empties2) = [];
                        elseif nG==3
                            orden3 = cell2table(concat); writetable(orden3,'ordeng3.csv');
                            orden3= table2cell(orden3); empties3 = find(cellfun(@isempty,orden3)); orden3(empties3) = [];
                        elseif nG==4
                            orden4 = cell2table(concat); writetable(orden4,'ordeng4.csv');
                            orden4= table2cell(orden4);  empties4 = find(cellfun(@isempty,orden4)); orden4(empties4) = [];
                        elseif nG==5
                            orden5 = cell2table(concat); writetable(orden5,'ordeng5.csv');
                            orden5= table2cell(orden5);  empties5 = find(cellfun(@isempty,orden5)); orden5(empties5) = [];
                        end
                    end %numCaract
                    
                end %Particion                
            end%Rep
                    vectAUC=mean(matAUC);
                    vect_std=std(matAUC);
                    matConfusion=matConfusion/nRep;
                    [maxAUC,numJ]=max(vectAUC);
                    marcador=(nG-1)*NM*NFS+(nM-1)*NFS+nFS;
            t1=toc;
                    eval(marcador+1,:)={marcador,vectAUC,maxAUC,vect_std,vect_std(numJ),...
                        nG,typM,typFS,numJ,matConfusion,t1};
        end %FS
    end %Modelo
end % NG

[percentatget1_1,percentatget2_1,percentatgeflair_1] = percentatge(orden1);
percentatge_ng1=[percentatget1_1,percentatget2_1,percentatgeflair_1];
[percentatget1_2,percentatget2_2,percentatgeflair_2] = percentatge(orden2);
percentatge_ng2=[percentatget1_2,percentatget2_2,percentatgeflair_2];
[percentatget1_3,percentatget2_3,percentatgeflair_3] = percentatge(orden3,typM);
percentatge_ng3=[percentatget1_3,percentatget2_3,percentatgeflair_3];
[percentatget1_4,percentatget2_4,percentatgeflair_4] = percentatge(orden4,typM);
percentatge_ng4=[percentatget1_4,percentatget2_4,percentatgeflair_4];
[percentatget1_5,percentatget2_5,percentatgeflair_5] = percentatge(orden5,typM);
percentatge_ng5=[percentatget1_5,percentatget2_5,percentatgeflair_5];

c = categorical({'NG1','NG2','NG3', 'NG4', 'NG5'});
y = [percentatge_ng1; percentatge_ng2; percentatge_ng3;percentatge_ng4;percentatge_ng5];
b=bar(c,y);
set(b, {'DisplayName'}, {'T1','T2','FLAIR'}')
ylabel('Percentatge(%)');
legend() 

%% Plotegem AUC (Cross Validation) en funció del numero de gris
aucplot = eval(:,[3,6,7,9]);
aucplot(1,:)=[];
maxauc = aucplot(:,1);
ng=aucplot(:,2);
tipusmodel=aucplot(:,3);
representar3(maxauc,ng,tipusmodel,1);

%% Plotegem matriu dels valors amb valor max de cada model
%          predicted
%         | 1     0
%    r  -----------
%    e  1 | TP   FN
%    a  0 | FP   TN
%    l
CM = eval(:,[6,9,10]);
CM(1,:)=[];
nivell= CM(:,1);
caract = CM(:,2);
conf=CM(:,3);
[sensitivity,specificity,accuracy]=representar2(caract,conf);
% sensitivity = cell2table(sensitivity);
% writetable(sensitivity,'sensitivity.csv');
% specificity = cell2table(specificity);
% writetable(specificity,'specificity.csv');
% accuracy = cell2table(accuracy);
% writetable(accuracy,'accuracy.csv');

%% Plotegem vectAUC
paraplot = eval(:,[2,3,6,7,9]);
paraplot(1,:)=[];
gris = paraplot(:,3);
max=paraplot(:,2);
vect=paraplot(:,1);
mod=paraplot(:,4);
car=paraplot(:,5);
for n=1:height(gris)
   representar(gris,vect,max,car,n);
end
