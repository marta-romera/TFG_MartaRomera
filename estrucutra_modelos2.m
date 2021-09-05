clear all;
home = cd;
%% Declaracio de variables pels models 
filename_csv ='TFG_Marta2.csv';
filename_xls ='TFG_Marta2.xls'; 
NM=3;
NFS=1; 
NG=5;
particiones=5 ; 
nRep=1;
k=5; 
NumNeighbors=3;
posclass=1;
rng(1) 
marcador=1;
eval(marcador,:)={'Intento','vectAUC','maxAUC','vect_std','vect_std',...
            'Nivel Gris','Tipo modelo','Tipo Filt o Wrap', 'Numero características','matConfusion','Tiempo'};   
%% Carreguem taula csv
% T_csv = readtable(filename_csv);
T_xls = readtable(filename_xls); 
tumorvsmetastasi = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1] %Definim el label que volem determinar
T_xls.Type = transpose(tumorvsmetastasi);
cabeceras = T_xls.Properties.VariableNames;

for nG=1:NG
    [label,data,new_cabeceras] = cargar(T_xls,cabeceras,nG); 
    label=data(:,1);
    data(:,1)=[];
    new_cabeceras(:,1)=[];
    numCaract=size(data,2); 

    for nM=1:NM
        rng(1);
        for nFS=1:NFS 
            tic 
            matConfusion=zeros(2,2,numCaract); 
            matAUC=zeros(particiones*nRep, numCaract); 
            vectAUC=zeros(1,numCaract); 
            for rep=1:1 %nRep
                c=cvpartition(label,'KFold',5); 
                for i=1:particiones 
                    % Definimos matrices de datos y vectores etiquetas
                    dTrain= data(c.training(i),:);
                    lTrain=label(c.training(i),1);
                    dTest= data(c.test(i),:);
                    lTest=label(c.test(i),1);
                    dTrain = normalize(dTrain); 
                    dTest = normalize(dTest);
                    [ranks(i,:),typFS] = extractCaract(dTrain,lTrain,k,nG);
                    for j=1:numCaract 
                        %% Extracció de predictors i percentatges
                        features=ranks(1:j);
                        for rank= 1:numel(features)
                            val = ranks(rank);
                            if typFS(rank)>=0 
                                concat{rank}= new_cabeceras(val);
                            else concat{rank}=[];
                            end
                        end
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
                        celda_puntuar(nG,nM,nFS,rep,i,j)={features};
                        [modelo,typM] = entrenarModelo2(nM,dTrain(:,features),lTrain);
                        [lPredict,scores]=predict(modelo,dTest(:,features)); %aquesta funcio et permet predir la teva AUC 
                        [X,Y,~,AUC] = perfcurve(lTest,scores(:,2),posclass);  %genera la AUC --> [X,Y,T,AUC] = perfcurve(labels,,)
                        C = confusionmat(lTest,lPredict); %genera la matriu de confusio --> C = confusionmat(group,grouphat)
                        matConfusion(:,:,j)=matConfusion(:,:,j)+C;
                        matAUC((rep-1)*particiones+i,j)=AUC;
                    end %numCaract
                end %Partició                
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
    end %Model
end % NG

%% Calcul percentatge
[percentatget1_1,percentatget2_1,percentatgeflair_1] = percentatge(orden1);
percentatge_ng1=[percentatget1_1,percentatget2_1,percentatgeflair_1];
[percentatget1_2,percentatget2_2,percentatgeflair_2] = percentatge(orden2);
percentatge_ng2=[percentatget1_2,percentatget2_2,percentatgeflair_2];
[percentatget1_3,percentatget2_3,percentatgeflair_3] = percentatge(orden3);
percentatge_ng3=[percentatget1_3,percentatget2_3,percentatgeflair_3];
[percentatget1_4,percentatget2_4,percentatgeflair_4] = percentatge(orden4);
percentatge_ng4=[percentatget1_4,percentatget2_4,percentatgeflair_4];
[percentatget1_5,percentatget2_5,percentatgeflair_5] = percentatge(orden5);
percentatge_ng5=[percentatget1_5,percentatget2_5,percentatgeflair_5];

c = categorical({'NG1','NG2','NG3', 'NG4', 'NG5'});
y = [percentatge_ng1; percentatge_ng2; percentatge_ng3;percentatge_ng4;percentatge_ng5];
b=bar(c,y);
set(b, {'DisplayName'}, {'T1','T2','FLAIR'}')
ylabel('Percentatge(%)');
legend() 

%% Plotegem AUC (Cross Validation) en funció del tipus model
aucplot = eval(:,[3,6,7,9]);
aucplot(1,:)=[];
maxauc = aucplot(:,1);
ng=aucplot(:,2);
tipusmodel=aucplot(:,3);
representar3(maxauc,ng,tipusmodel,1);
%% Plotegem matriu dels valors amb valor max de cada model
%          predicted
%         | 0     1
%    r  -----------
%    e  0 | TN   FP
%    a  1 | FN   TP
%    l
CM = eval(:,[6,9,10]);
CM(1,:)=[];
nivell= CM(:,1);
caract = CM(:,2);
conf=CM(:,3);
[sensitivity,specificity,accuracy]=representar2(caract,conf);
% % sensitivity = cell2table(sensitivity);
% % writetable(sensitivity,'sensitivity.csv');
% % specificity = cell2table(specificity);
% % writetable(specificity,'specificity.csv');
% % accuracy = cell2table(accuracy);
% % writetable(accuracy,'accuracy.csv');
% 
% %% Plotegem vectAUC en funció de cada nivell de gris
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

