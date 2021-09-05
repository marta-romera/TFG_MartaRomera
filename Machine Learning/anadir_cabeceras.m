function [new_table,label] = anadir_cabeceras(T, singeneral)
new_cabeceras = singeneral.Properties.VariableNames;% Extraemos las cabeceras del archivo csv

for x= 1:height(T)

    if (strcmp('T1',T.Origin(x))==1)
        t1(x,:) = singeneral(x,:);
        cabecerat1 = append(new_cabeceras,'_T1');
        t1.Properties.VariableNames = cabecerat1;
        t1_new = t1(:,:);
        fin1=x;
    elseif (strcmp('T2',T.Origin(x))==1)
        t2(x,:) = singeneral(x,:);
        cabecerat2 = append(new_cabeceras,'_T2');
        t2.Properties.VariableNames = cabecerat2;
        t2_new = t2(:,:);
        t2_new(1:fin1,:)=[];
        fin2=x;
    elseif (strcmp('flair',T.Origin(x))==1)
        flair(x,:) = singeneral(x,:);
        cabeceraflair = append(new_cabeceras,'_FLAIR');
        flair.Properties.VariableNames = cabeceraflair;
        flair_new = flair(:,:);
        flair_new(1:fin2,:)=[];
    end
    
end
label = T(1:fin1,3); %Equivale al label
new_table = [label t1_new t2_new flair_new]; %Tabla con las caracteristicas nuevas concatenadas

end
