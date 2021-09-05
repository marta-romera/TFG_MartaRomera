%Función que separa por secuencias el csv en funcion del origin de la tabla
%las cabeceras y las agrupa en una nueva tabla.
function [label,data,new_cabeceras] = cargar(T,cabeceras,nG)
%Diferenciamos entre los valores generales y el resto
general_new = T(:,1:7); 

for h= 8:numel(cabeceras) %Empezamos des del ultimo valor del general
    new_cabeceras(h)=cabeceras(h);
    singeneral= T(:,8:h);
end

emptiess = find(cellfun(@isempty,new_cabeceras));
new_cabeceras(emptiess) = []; % eliminamos celdas vacias

%Ordenem nivell de grisos 1 al 5
for c = 1:numel(new_cabeceras)
     n1(c)=contains(new_cabeceras(c),'NG1');
     n2(c)=contains(new_cabeceras(c),'NG2');
     n3(c)=contains(new_cabeceras(c),'NG3');
     n4(c)=contains(new_cabeceras(c),'NG4');
     n5(c)=contains(new_cabeceras(c),'NG5');
        if n1(c)==1
            ng1(c) = new_cabeceras(c);
            empties = find(cellfun(@isempty,ng1)); % identify the empty cells
            ng1(empties) = [];                     % remove the empty cells
            ng1_table = singeneral(:,n1==1);
        elseif n2(c)==1
            ng2(c) = new_cabeceras(c);
            empties = find(cellfun(@isempty,ng2));
            ng2(empties) = [];
            ng2_table = singeneral(:,n2==1);
        elseif n3(c) ==1
            ng3(c) = new_cabeceras(c);
            empties = find(cellfun(@isempty,ng3));
            ng3(empties) = [];
            ng3_table = singeneral(:,n3==1);
        elseif  n4(c) ==1
            ng4(c) = new_cabeceras(c);
            empties = find(cellfun(@isempty,ng4));
            ng4(empties) = [];
            ng4_table = singeneral(:,n4==1);
        elseif  n5(c) ==1
            ng5(c) = new_cabeceras(c);
            empties = find(cellfun(@isempty,ng5));
            ng5(empties) = [];  
            ng5_table = singeneral(:,n5==1);
        else
            general=singeneral(:,1:3); %Son general pero no contienen NG
        
        end
end

if nG==1
    total_ng1= [general_new ng1_table];
    ng1_singeneral=[general ng1_table]; %No contenen NGx
    [new_table,label] = anadir_cabeceras(total_ng1,ng1_singeneral); %Funcion para añadir las cabeceras
    writetable(new_table,'ng1.csv'); %Un cop l'hem creat no el tornem a compilar
    data = [];
     data = xlsread('ng1.xls');
elseif nG==2
    total_ng2= [general_new ng2_table];
    ng2_singeneral=[general ng2_table];
    [new_table,label] = anadir_cabeceras(total_ng2,ng2_singeneral);
    writetable(new_table,'ng2.csv');
    data = [];
     data = xlsread('ng2.xls');
elseif nG==3
    total_ng3= [general_new ng3_table];
    ng3_singeneral=[general ng3_table];
    [new_table,label] = anadir_cabeceras(total_ng3,ng3_singeneral); 
    writetable(new_table,'ng3.csv'); 
    data = [];
     data = xlsread('ng3.xls');
elseif nG==4
    total_ng4= [general_new ng4_table];
    ng4_singeneral=[general ng4_table];
    [new_table,label] = anadir_cabeceras(total_ng4,ng4_singeneral);
    writetable(new_table,'ng4.csv'); 
    data = [];
     data = xlsread('ng4.xls');
elseif nG==5
    total_ng5= [general_new ng5_table];
    ng5_singeneral=[general ng5_table];
    [new_table,label] = anadir_cabeceras(total_ng5,ng5_singeneral);
    writetable(new_table,'ng5.csv');
    data = [];
    data = xlsread('ng5.xls');
end

new_cabeceras = new_table.Properties.VariableNames;% Extraemos las cabeceras del archivo csv

end

