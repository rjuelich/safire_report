%PlotFullMeanCorr_Matrix.m, 120626 avram
% v 1.2 minor bug fix; corrected error in surface map loop; added eps 2D
% matrix output

%Example:
%PlotFullMeanCorr_Matrix('ASD_RESTvMOVIE','ASD_RESTvMOVIE','/cluster/nexus/3/users/holmes/NA_procSurfFast/output/',1.301,1,2,1,'/cluster/nexus/19/users/mhollins/MOVIES/','/autofs/eris/sbdp/GSP_Subject_Data/SCRIPTS/Surface_ROIs/ROIList_networkcomponents_017.symmetric.',0,'AllBoldRuns')
%Input must be a csv file:
%Col1 Subj ID
%Col2 target variable
%Col3-max covariates 

% returns the 3d correlation matrix as well as a vertex count giving the
% size of each ROI
% vertex_count

%Must have PlotCorrMatrix.m in the script folder. This is the script that
%does the graphing

function []=PlotFullMean_Indiv_130530(SaveName,inputData,corrMattFolder, PvalueThresh, regYes, ConsiderCovars, surfYes, surfLoc, labelData, matrixYes, defMRI) 

%TO BE COMMENTED IN/OUT when piloting
%SaveName=('Taplin.data')
%inputData=('Taplin.data')
%corrMattFolder=('Analyses/PlotFullMean_130530/')
%PvalueThresh= 2.11
%regYes = 2
%ConsiderCovars = 1
%surfYes = 0
%surfLoc = ('Skipping')
%labelData = ('/autofs/eris/sbdp/GSP_Subject_Data/SCRIPTS/Surface_ROIs/ROIList_networkcomponents_017.symmetric.') 	
%matrixYes = 1
%defMRI = ('AllBoldRuns')

%Add Thomas' path
addpath('/cluster/nrg/tools/0.9.8.2/code/bin/'); 
ythomas_generic_startup;

%Loads 2D matrix color tables
load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/colorscale.mat');

fid = fopen([inputData '.csv'], 'r');
count = 1;
while(1)
    tline = fgetl(fid);
    if ~ischar(tline)
       break; 
    else
        TempVar = textscan(tline, '%[^,]');
        filenames{count} = TempVar{1}{1};
        count = count + 1;
    end
end

%Reads in the surface ROIs assumes lh/rh lists match
fid = fopen([labelData 'lh.txt'], 'r');
count = 1;
while(1)
    tline = fgetl(fid);
    if ~ischar(tline)
       break; 
    else
        TempVar = textscan(tline, '%[^,]');
        [a,b,c]=fileparts(TempVar{1}{1});
        labelnames{count} = [b c];
        count = count + 1;
    end
end

%Sets axis names for 2D plots
for labelnum = 1:length(labelnames)
    TempVar = textscan(labelnames{labelnum}, '%s','delimiter', '_');
    axisnames{labelnum} = TempVar{1}{3};
end


[networknames,networkstart]=unique(axisnames(:));

for labelnum = 1:length(networknames)
    axisloc{labelnum} = median(find(strcmpi(axisnames,networknames(labelnum))));
    networkstart(labelnum) = min(find(strcmpi(axisnames,networknames(labelnum))));
end

%sorts data for graphing
axisLocMat = cell2mat(axisloc);
[sortedMat,sortInds]=sort(axisLocMat);
networkstart = networkstart(sortInds);

%loads the target variable and covariates file
VarStore = load([inputData '.csv']);
VarSize = size(VarStore);
targvec=VarStore(:,2);
covec=VarStore(:,3:VarSize(2));
nsubjects = VarSize(1);
 
%load the corrlation matrix corresponding to the hemispheres you want 
pathtoProj = [corrMattFolder];

%Import each Corr mat file
clear corr_mat


%Run 2D matrix analyses if matrixYes flag is set to 1
if (matrixYes == 1)
    %Import each groups Corr mat files
    pathTo_lh_lh = fullfile(pathtoProj, [inputData '_lh_lh_ROIList_networkcomponents_017.symmetric.lh.mat']);
    pathTo_rh_rh = fullfile(pathtoProj, [inputData '_rh_rh_ROIList_networkcomponents_017.symmetric.rh.mat']);
    pathTo_lh_rh = fullfile(pathtoProj, [inputData '_lh_rh_ROIList_networkcomponents_017.symmetric.lh_rh.mat']);

    load(pathTo_lh_lh);
    corr_mat_lh_lh = corr_mat;
    load(pathTo_rh_rh);
    corr_mat_rh_rh = corr_mat;
    load(pathTo_lh_rh);
    corr_mat_lh_rh = corr_mat;

    numCond = size(corr_mat_lh_lh);

    fullMat_lh_lh = zeros(numCond(1),numCond(2),numCond(3));
    fullMat_lh_lh(:,:,1:numCond(3)) = StableAtanh(corr_mat_lh_lh);

    fullMat_rh_rh = zeros(numCond(1),numCond(2),numCond(3));
    fullMat_rh_rh(:,:,1:numCond(3)) = StableAtanh(corr_mat_rh_rh);

    fullMat_lh_rh = zeros(numCond(1),numCond(2),numCond(3));
    fullMat_lh_rh(:,:,1:numCond(3)) = StableAtanh(corr_mat_lh_rh);

    numTot = size(fullMat_lh_lh);
    
    zeroMat=zeros(numCond(1),numCond(2),numCond(3));
    for i=1:numTot(1)
        for jj=1:numTot(2)
            if (jj>i)
                fullMat_lh_lh(i,jj,:) = zeroMat(i,jj,:);
                fullMat_rh_rh(i,jj,:) = zeroMat(i,jj,:);
       %         fullMat_lh_rh(i,jj,:) = zeroMat(i,jj,:);
            end
        end
    end

	% Save out individual subject grids
	%
	for subj=1:numTot(3)

	    BH_indiv_corr_mat = zeros(numTot(1),numTot(2));

	    indiv_corr_mat_rh_rh_trans=fullMat_rh_rh(:,:,subj)';
	    %Not considering lh_rh correlations
	    %mean_corr_mat_rh_lh = mean_corr_mat_lh_rh';
	    for i=1:numTot(1)
		for jj=1:numTot(2)
		    if (jj>i)
			BH_indiv_corr_mat(i,jj) = indiv_corr_mat_rh_rh_trans(i,jj);
		    else
			BH_indiv_corr_mat(i,jj) = fullMat_lh_lh(i,jj,subj);
		    end
		    if (jj==i)
			BH_indiv_corr_mat(i,jj) = 0;
		    end
		end
	    end
	    %save the indiv residual correlation matrices
	    outname = fullfile(pathtoProj, [SaveName '_' filenames{subj} '_BH_indiv_corr_mat.txt']);
	    dlmwrite(outname,BH_indiv_corr_mat,'delimiter','\t','precision','%2.3f'); 
	    
	    %Figure save name/location
	    figName = fullfile(pathtoProj, [SaveName '_' filenames{subj} '_BH_indiv_corr_mat']);
	    
	    %plot the group's mean correlation matrix 
	    PlotCorrMatrix(BH_indiv_corr_mat,figName,labelData)
	end
end

