function [FS,errorfiles] = RadiomicsTA_2D(dirname,filename,scanType)
%RADIOMICSTA performs the Texture Analysis of the region specified by roi3D
%over the T13D image using RADIOMICS functions

%Open directory with Analysis variables
files=dir([dirname '/*.mat']);
files_cell={files.name};

% VARIABLE PARAMETERS
% - scanType: String specifying the type of scan analyzed. Either 'PETscan', 
%             'MRscan' or 'Other'.

% - R: Numerical value specifying the ratio of weight to band-pass coefficients 
%      over the weigth of the rest of coefficients (HHH and LLL). Provide R=1 
%      to not perform wavelet band-pass filtering.
% R=[1/2 2/3 1 3/2 2]; % Wavelet band-pass filtering 
% R=[1 2 3 4 5];   % Decomposition
 R=1;

% - scale: Numerical value specifying the scale at which 'volume' is isotropically 
%          resampled (mm). If a string 'pixelW' is entered as input, the
%          volume will be isotropically resampled at the initial in-plane
%          resolution of 'volume' specified by 'pixelW'.
scale={'pixelW'};       

% - quantAlgo: String specifying the quantization algorithm to use on 'volume'. 
%              Either 'Equal' for equal-probability quantization, 'Lloyd'
%              for Lloyd-Max quantization, or 'Uniform' for uniform quantization.
%              Use only if textType is set to 'Matrix'.
quantAlgo='Equal';

% - Ng: Integer specifying the number of gray levels in the quantization process.
%       Use only if textType is set to 'Matrix'.
Ng=2.^(4:8);   % Ng=16-256


GTstr=struct;
GLCMstr=struct;
GLRLMstr=struct;
GLSZMstr=struct;
NGTDMstr=struct;

globalTime=tic;

steps=length(files_cell);
step=0;
strwb=['Analyzing Case ','1/',num2str(steps)];
hwb = waitbar(0,strwb,'Name', 'CALCULATING TEXTURES...');
errorfiles={};

for i=1:3 %Ponemos este rango para no mostrar el tumor en el .csv

    OneCaseTime = tic;
    % INPUT VOLUMES AND PREDEFINED VALUES
    a = load([dirname '\' files_cell{i}]);
    b = load([dirname '\' files_cell{4}]); %Lo creamos para guardar el roi3D y hacer la mask
    
    % CARREGUEM INFO .mat
    %---------------------LesType--------------------
    if isfield(a,'LesType')
        LesType = a.LesType;
    end
    %---------------------Origin---------------------
    if isfield(a,'Origin')
        Origin = a.Origin;
    end
    
    for x= 1:17 % Num de pacients (17)
    %-------------------total_volume-----------------
        if (isfield(a,'total_V_T1_new')== 1)
          brain3D=cell2mat(a.total_V_T1_new(x));
        elseif (isfield(a,'total_V_T2')== 1)
            brain3D=cell2mat(a.total_V_T2(x));
        elseif (isfield(a,'total_V_flair_new')== 1)
           brain3D=cell2mat(a.total_V_flair_new(x));
        end
        if isfield(b,'total_V_tumor')
            roi3D=cell2mat(b.total_V_tumor(x));
        end
    %----------------------name------------------
        if isfield(a,'name')
          PatientID=cell2mat(a.name(x));
        end
    %------------------StudyDate-----------------
        if isfield(a,'StudyDate')
          StudyDate=cell2mat(a.StudyDate(x));
        end
    %--------------------Resolution------------------
    if (isfield(a,'Resx1')== 1)
          Resolution=cell2mat(a.Resx1(x));
    end
    if (isfield(a,'Resx2')== 1)
          Resolution=cell2mat(a.Resx2(x));
    end
    if (isfield(a,'Resx3')== 1)
          Resolution=cell2mat(a.Resx3(x));
    end
    if isfield(b,'Resx4')
         Resolution=cell2mat(b.Resx4(x));
    end
    %-------------------InitialSlice-----------------
    if isfield(b,'InitialSlice')
        InitialSlice= cell2mat(b.InitialSlice(x)); %Ho agafem a partir del tumor
    end

    % - volume: 2D or 3D array containing the medical images to analyze
    volume=brain3D(:,:,InitialSlice);
    
    % - mask: 2D or 3D array of dimensions corresponding to 'volume'. The mask
    %         contains 1's in the region of interest (ROI), and 0's elsewhere.
    mask=roi3D(:,:,InitialSlice);
   
    % - pixelW: Numerical value specifying the in-plane resolution (mm) of 'volume'.
    pixelW=Resolution(1);
    
    % - sliceS: Numerical value specifying the slice spacing (mm) of 'volume'.
    %           Put a random number for 2D analysis.
    sliceS=0;   % Resolution(3) is not valid because this parameter vary.

    %Getting the Volume and the Longest Diameter
    %numpix=length(find(mask==1));
    boxBound= computeBoundingBox(mask);
    maskBox = double(mask(boxBound(1,1):boxBound(1,2),...
        boxBound(2,1):boxBound(2,2)));
    maskBox(maskBox==0)=NaN;
    volROI= getVolume(maskBox,pixelW,sliceS);
    sizeROI= getSize(maskBox,pixelW,sliceS);
    
    % Change depending on the analysis
    % ANALYSIS MTS - RDN: ('Type',LesType)
    % ANALYSIS ORIGIN: ('Origin',Origin)

%     GTonestr=struct('ID',PatientID,'StudyDate',StudyDate,'Type',LesType,...
%         'Origin',Origin,'PIRADS',PIRADS,'Tumor',Tumor,'Nodulos',Nodulos,...
%         'Metastasis',Metastasis,'Position',InitialSlice,'Volume',volROI,'Size',sizeROI); 
    GTonestr=struct('ID',PatientID,'StudyDate',StudyDate,'Type',LesType,...
        'Origin',Origin,'Position',InitialSlice,'Volume',volROI,'Size',sizeROI);

    GLCMonestr=struct;
    GLRLMonestr=struct;
    GLSZMonestr=struct;
    NGTDMonestr=struct;

    % GLOBAL TEXTURES
    for r=1:length(R)
        for sc=1:length(scale)
            
            [ROIglobal] = prepareVolume(volume,mask,scanType,...
                pixelW,sliceS,R(r),scale{sc},'Global');

            globalTextures = getGlobalTextures(ROIglobal,100);

            names=fieldnames(globalTextures);
            for nms=1:length(names)
                newname=strcat(names(nms),'_GT_R',num2str(r),'SC',num2str(sc));
                globalTextures=RenameField(globalTextures,names(nms),newname);
            end
            GTonestr=catstruct(GTonestr,globalTextures);
        end
    end

    if i==1 && x == 1
        GTstr=GTonestr;
    else
        GTstr=[GTstr, GTonestr];
    end
    
    % MATRIX-BASED TEXTURES 
    for r=1:length(R)
        for sc=1:length(scale)
            for ng=1:length(Ng)
                
                [ROImatrix,levels] = prepareVolume(volume,mask,scanType,...
                    pixelW,sliceS,R(r),scale{sc},'Matrix',quantAlgo,Ng(ng));
                
                % GLCM TEXTURES (Grey-Level Co-occurence Matrix)
                GLCM = getGLCM(ROImatrix,levels);           % Calcula la co-occurence matrix por corte. 
                glcmTextures = getGLCMtextures(GLCM);       % Salida: energy, contrast, entropy, homogeneity, correlation, sumAverage, variance, dissimilarity, autoCorrelation.
                
                names=fieldnames(glcmTextures);
                for nms=1:length(names)
                    newname=strcat(names(nms),'_GLCM_R',num2str(r),...
                        'SC',num2str(sc),'NG',num2str(ng));
                    glcmTextures=RenameField(glcmTextures,names(nms),newname);
                end

                GLCMonestr=catstruct(GLCMonestr,glcmTextures);
     
                % GLRLM TEXTURES (Gray-Level Run-Length Matrix)
                GLRLM = getGLRLM(ROImatrix,levels);          % Calcula la grey-level run-length matrix por corte.
                glrlmTextures = getGLRLMtextures(GLRLM);     % Salida: SRE (short run emphasis), LRE (long run emphasis), GLN (gray-level nonuniformity), RLN (Run-Length Nonuniformity, RP (run percentage),
                % LGRE (low gray-level run emphasis), HGRE (high gray-level
                % run emphasis), SRLGE (short run low gray level emphasis),
                % SRHGE (short run high grey-level emphasis), LRLGE (long
                % run low gray-level emphasis), LRHGE (long run high
                % gray-level emphasis), GLV (gray level variance, RLV (run
                % length variance).
                
                names=fieldnames(glrlmTextures);
                for nms=1:length(names)
                    newname=strcat(names(nms),'_GLRLM_R',num2str(r),...
                        'SC',num2str(sc),'NG',num2str(ng));
                    glrlmTextures=RenameField(glrlmTextures,names(nms),newname);
                end

                GLRLMonestr=catstruct(GLRLMonestr,glrlmTextures);
     
                % GLSZM TEXTURES (Grey-Level Size Zone Matrix)
                GLSZM = getGLSZM(ROImatrix,levels);               % Calcula la gray-level size zone matrix
                glszmTextures = getGLSZMtextures(GLSZM);          % Salida: SZE (small zone emphasis), LZE (large zone emphasis), GLN (gray-level nonuniformity), ZSN (zone-size nonuniformity), RP (zone percentage), LGZE (low grey-level zone emphasis),
                % HGZE (highgray-level zone emphasis), SZLGE (small zone low gray-level emphasis), SZHGE (small zone high gray-level emphasis), LZLGE (large zone low gray-level emphasis), LZHGE (large zone high gray- level emphasis),
                % GLV (grey-level variance), ZSV (zone-size variance).
                
                names=fieldnames(glszmTextures);
                for nms=1:length(names)
                    newname=strcat(names(nms),'_GLSZM_R',num2str(r),...
                        'SC',num2str(sc),'NG',num2str(ng));
                    glszmTextures=RenameField(glszmTextures,names(nms),newname);
                end

                GLSZMonestr=catstruct(GLSZMonestr,glszmTextures);
    
                % NGTDM TEXTURES (Neighbourhood Gray-Tone Difference Matrix)
                [NGTDM,countValid] = getNGTDM(ROImatrix,levels);        % Calcula la Neighbourhood Gray-Tone Difference Matrix.
                ngtdmTextures = getNGTDMtextures(NGTDM,countValid);     % Salida: coarseness, contrast, busyness, complexity, strength.
                
                names=fieldnames(ngtdmTextures);
                for nms=1:length(names)
                    newname=strcat(names(nms),'_NGTDM_R',num2str(r),...
                        'SC',num2str(sc),'NG',num2str(ng));
                    ngtdmTextures=RenameField(ngtdmTextures,names(nms),newname);
                end

                NGTDMonestr=catstruct(NGTDMonestr,ngtdmTextures);                
  
            end
        end
    end
    
    if i==1 && x == 1
        GLCMstr=GLCMonestr;
        GLRLMstr=GLRLMonestr;
        GLSZMstr=GLSZMonestr;
        NGTDMstr=NGTDMonestr;
    else
        GLCMstr=[GLCMstr, GLCMonestr];
        GLRLMstr=[GLRLMstr, GLRLMonestr];
        GLSZMstr=[GLSZMstr, GLSZMonestr];
        NGTDMstr=[NGTDMstr, NGTDMonestr];
    end

    step=step+1;    
    strwb=['Analyzing Case ',num2str(i+1),'/',num2str(steps)];
    waitbar(step/steps,hwb,strwb);
    
    
    fprintf('i=%i: ',i)  
    toc(OneCaseTime);
    end
    
end

fprintf('TOTAL: ')    
toc(globalTime);

close(hwb);
FS=catstruct(GTstr,GLCMstr,GLRLMstr,GLSZMstr,NGTDMstr);

% Write to .mat and .csv file
filemat=[filename,'.mat'];
filecsv=[filename,'.csv'];
filexls=[filename,'.xls'];

if exist(filemat,'file')==2
   FSold=load(filemat);
   FeatureStr=[FSold.FeatureStr,FS];
else
   FeatureStr=FS; 
end

save(filemat,'FeatureStr')
T=struct2table(FeatureStr);
writetable(T,filexls)
writetable(T,filecsv)


