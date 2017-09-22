%=========================================================================
%
% This script couples with PlotFullMeanCorr_Matrix.m to generate output graphs


function PlotCorrMatrix(corr_mat,SaveName,labelData)

%Add Thomas' path
addpath('/cluster/vc/buckner/code/bin/'); 
ythomas_generic_startup;

%Loads 2D matrix color tables
load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/colorscale.mat');

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

%plot the group's mean correlation matrix 
%start by plotting the network start point. 
%note: plot3 has to be run before surf
hold on
for netnum = 1:length(unique(axisnames(:)))
    plot3(ones(1,62)*networkstart(netnum),1:62,-ones(1,62),'Color',[0.5 0.5 0.5],'LineWidth',1);
    plot3(1:62,ones(1,62)*networkstart(netnum),-ones(1,62),'Color',[0.5 0.5 0.5],'LineWidth',1);
end

%Add in 2D matrix data
%Pad Array for surf plotting
corr_mat_pad=padarray(corr_mat,[1,1],0,'post');
surf(corr_mat_pad,'EdgeColor','none')
set(gca,'YDir','reverse','XTickLabel',networknames(sortInds)','XTick',sortedMat,'Layer','top','FontName','Arial','FontSize',8);
set(gca,'YDir','reverse','YTickLabel',networknames(sortInds)','YTick',sortedMat,'Layer','top','FontName','Arial','FontSize',8);
view(225,-90);
xlim(gca,[1 62]);
ylim(gca,[1 62]);
set(gcf,'Colormap',rbmap2);
%Colorbar scaling
hcol=colorbar('peer',gca,'SouthOutside');
cpos=get(hcol,'Position');
cpos(4)=cpos(4)/3; % Halve the thickness
%           cpos(3)=cpos(3)/2; % Halve the width
cpos(2)=cpos(2) - 0.1; % Move it down outside the plot
%           cpos(1)=cpos(1) - 0.1; % Move it left outside the plot
set(hcol,'Position',cpos);
%limit = 1.5
limit = abs(max(max(corr_mat_pad)));
if (abs(max(max(corr_mat_pad))) < abs(min(min(corr_mat_pad))))
    limit = abs(min(min(corr_mat_pad)));
end
set(gca, 'CLim', [-limit,limit]);
%Save figures
print(gcf,[SaveName,'.eps'],'-depsc','-r300');
print(gcf,[SaveName,'.jpg'],'-djpeg','-r300');
print(gcf,[SaveName,'.jpg'],'-djpeg','-r300');
close all;
