clear all;

%%Accedim al directori on estan els pacients
home = cd;
cd([cd,'\Segmentaciones'])
path2 = cd;
lista_casos = dir;

%%Recorrem el bucle dels pacients per treure la informació necessaria
for x = 3:length(lista_casos)
    
    cd([path2,'\',lista_casos(x).name]);
    path3 = cd;
    data = dir;
    
    cd([path3,'\', data(3).name]);
    path4 = cd;
    grupos = dir;
    
    %% A cada pacient trobem la informació relacionada amb 4 secuencies: FLAIR, T2,T1 i Tumor 
    for i = 3:length(grupos)
        %%----------------------------------FLAIR
        flair_expression = strcmp(grupos(i).name,'FLAIR')
        if (flair_expression == 1)
            cd([path4,'\', grupos(i).name]);
            flair = dir;
            for j= 3:length(flair) %Acedim a les imatges per canviar ImageOrientationPatient
                X = dicomread([strcat(flair(j).folder, '\', flair(j).name)]);
                info_flair = dicominfo(flair(j).name);
                if (j==3)
                    reference_orientation = info_flair.ImageOrientationPatient;
                else
                    info_flair.ImageOrientationPatient = reference_orientation;
                end
             %Creem un nou directori FLAIR para guardar les imatges creades
                if ~exist('FLAIR_orientated', 'dir')
                    mkdir([path4,'\','FLAIR_orientated']);
                end
                cd([path4,'\', 'FLAIR_orientated'])
                flair_orientated = dir;
                dic = sprintf('I_0%d.dcm', j);
                dicomwrite(X,dic, info_flair);
                cd([path4,'\', grupos(i).name]);
            end
            V_flair = dicomreadVolume([path4,'\', 'FLAIR_orientated']);
            V_flair = squeeze(V_flair);
            total_V_flair{x} = V_flair; %Guardem els volums FLAIR de tots els pacients
        end
        %%------------------T1      
        T1_expression = strcmp(grupos(i).name,'T1')
        if(T1_expression == 1)
            cd([path4,'\', grupos(i).name]);
            T1 = dir;
            for j= 3:length(T1)
                X = dicomread([strcat(T1(j).folder, '\', T1(j).name)]);
                info_T1 = dicominfo(T1(j).name);
                if (j==3)
                    reference_orientation = info_T1.ImageOrientationPatient;
                else
                    info_T1.ImageOrientationPatient = reference_orientation;
                end
                if ~exist('T1_orientated', 'dir')
                    mkdir([path4,'\','T1_orientated']);
                end
                cd([path4,'\', 'T1_orientated'])
                T1_orientated = dir;
                dic = sprintf('I_0%d.dcm', j);
                dicomwrite(X,dic, info_T1);
                cd([path4,'\', grupos(i).name]);
            end
            V_T1 = dicomreadVolume([path4,'\', 'T1_orientated']);
            V_T1 = squeeze(V_T1);
            total_V_T1{x} = V_T1;
        end 
        %%------------------T2
        T2_expression = strcmp(grupos(i).name,'T2')
        if(T2_expression ==1)
            cd([path4,'\', grupos(i).name]);
            T2 = dir;
            for j= 3:length(T2)
                X = dicomread([strcat(T2(j).folder, '\', T2(j).name)]);
                info_T2 = dicominfo(T2(j).name);
                if (j==3)
                    reference_orientation = info_T2.ImageOrientationPatient;
                else
                    info_T2.ImageOrientationPatient = reference_orientation;
                end
                if ~exist('T2_orientated', 'dir')
                    mkdir([path4,'\','T2_orientated']);
                end
                cd([path4,'\', 'T2_orientated'])
                T2_orientated = dir;
                dic = sprintf('I_0%d.dcm', j);
                dicomwrite(X,dic, info_T2);
                cd([path4,'\', grupos(i).name]);
            end
            V_T2 = dicomreadVolume([path4,'\', 'T2_orientated']);
            V_T2 = squeeze(V_T2);
            total_V_T2{x} = V_T2;
            %intensity = [0 20 40 120 220 1024]; alpha = [0 0 0.15 0.3 0.38 0.5]; color = ([0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255])/ 255; queryPoints = linspace(min(intensity),max(intensity),256); alphamap = interp1(intensity,alpha,queryPoints)'; colormap = interp1(intensity,color,queryPoints);
            %ViewPnl = uipanel(figure,'Title','4-D Dicom Volume');
            %volshow(V_T2,'Colormap',colormap,'Alphamap',alphamap,'Parent',ViewPnl);
        end    
        %%------------------Tumor       
        tumor_expression = strcmp(grupos(i).name,'Tumor')
        if (tumor_expression==1)
            cd([path4,'\', grupos(i).name]);
            tumor = dir;
            for j= 3:length(tumor)
                X = dicomread([strcat(tumor(j).folder, '\', tumor(j).name)]);
                info_tumor = dicominfo(tumor(j).name);
                if (j==3)
                    reference_orientation = info_tumor.ImageOrientationPatient;
                else
                    info_tumor.ImageOrientationPatient = reference_orientation;
                end
                 if ~exist('Tumor_orientated', 'dir')
                    mkdir([path4,'\','Tumor_orientated']);
                end
                cd([path4,'\', 'Tumor_orientated'])
                tumor_orientated = dir;
                dic = sprintf('I_0%d.dcm', j);
                dicomwrite(X,dic, info_tumor);
                cd([path4,'\', grupos(i).name]);
            end
            V_tumor = dicomreadVolume([path4,'\', 'Tumor_orientated']);
            V_tumor = squeeze(V_tumor);
            total_V_tumor{x} = V_tumor;
        end 
    end
    
    %%Guardem la informació per crear el .mat i el .csv
    name{x} = lista_casos(x).name; %Posem el nom de les carpetes
    StudyDate{x}=info_tumor.StudyDate;
    [~,~, v] = ind2sub(size(total_V_tumor{x}), find(total_V_tumor{x} > 0));
    InitialSlice{x} = unique(v);
    Resx1{x} = info_tumor.PixelSpacing(1);
    Resx2{x} = info_flair.PixelSpacing(1);
    Resx3{x} = info_T1.PixelSpacing(1);
    Resx4{x} = info_T2.PixelSpacing(1);      
end

%% Eliminem els espais buits ([]) de las variables
empties1 = find(cellfun(@isempty,total_V_flair)); total_V_flair(empties1) = [];                    
empties2 = find(cellfun(@isempty,total_V_T2)); total_V_T2(empties2) = [];                   
empties3 = find(cellfun(@isempty,total_V_T1));total_V_T1(empties3) = [];
empties4 = find(cellfun(@isempty,total_V_tumor)); total_V_tumor(empties4) = [];                     
empties5 = find(cellfun(@isempty,name)); name(empties5) = [];
empties6 = find(cellfun(@isempty,StudyDate)); StudyDate(empties6) = [];
empties7 = find(cellfun(@isempty,InitialSlice)); InitialSlice(empties7) = [];
empties8 = find(cellfun(@isempty,Resx1)); Resx1(empties8) = [];
empties9 = find(cellfun(@isempty,Resx2)); Resx2(empties9) = [];
empties10 = find(cellfun(@isempty,Resx3)); Resx3(empties10) = [];
empties11 = find(cellfun(@isempty,Resx4)); Resx4(empties11) = [];

%%
%-----------Fem el resize de les matrius del volum 
for y = 1:length(total_V_flair)
    mida_flair = size(total_V_flair{y});
    mida_flair(:,3)=[];
    mida_t1=size(total_V_T1{y});
    mida_t1(:,3)=[];
    
    if  isequal(mida_flair, mida_t1)    %Rellenamos los huecos libres
        total_V_flair_new{y}= total_V_flair{y};
        total_V_T1_new{y}= total_V_T1{y};
    end
    if mida_flair< mida_t1
        I1= total_V_flair{y};
        J1 = imresize(I1,2);
        total_V_flair_new{y}=J1;
        total_V_T1_new{y}= total_V_T1{y};
    elseif mida_flair > mida_t1
        I2= total_V_T1{y};
        J2 = imresize(I2,2);
        total_V_T1_new{y}=J2;
        total_V_flair_new{y}= total_V_flair{y};
    end
   
end

%%
%-----------------------Creem el .mat
cd(home) %Ho guardem en Segmentacions
LesType= 1; %Sera el meu input 1 positiu (maligne) i 0 (benigne)
Origin = 'tumor';
save roi3D total_V_tumor Resx1 InitialSlice name LesType Origin StudyDate
Origin = 'flair';
save brain3D_flair total_V_flair_new Resx2 InitialSlice name LesType Origin StudyDate
Origin = 'T1';
save brain3D_T1 total_V_T1_new Resx3 InitialSlice name LesType Origin StudyDate
%------------------T2
Origin = 'T2';
save brain3D_T2 total_V_T2 Resx4 InitialSlice name LesType Origin StudyDate

%%
%------------------Funció RadiomicsTA_2D
home = cd;
dirname = cd([cd,'\Resultats'])% directorio on es trobarem els arxius .mat
filename = 'TFG_Marta'; % nom del fitxer on es guarden els resultats
[FS,errorfiles] = RadiomicsTA_2D(dirname, filename,'MRscan')

