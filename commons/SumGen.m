function SumGen(sub)

ContAMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/ContA.txt');
ContBMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/ContB.txt');
ContCMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/ContC.txt');
DefaultAMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/DefaultA.txt');
DefaultBMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/DefaultB.txt');
DefaultCMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/DefaultC.txt');
DefaultDMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/DefaultD.txt');
DorsAttnAMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/DorsAttnA.txt');
DorsAttnBMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/DorsAttnB.txt');
LimbicMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/Limbic.txt');
SalMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/Sal.txt');
SomMotAMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/SomMotA.txt');
SomMotBMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/SomMotB.txt');
VentAttnMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/VentAttn.txt');
VisCentMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/VisCent.txt');
VisPeriMean=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/NET_MEANS_n2642/VisPeri.txt');

names={'VisCent','VisPeri','SomMotA','SomMotB','DorsAttnA','DorsAttnB','VentAttn','Sal','Limbic','ContA','ContB','ContC','DefaultA','DefaultB','DefaultC','DefaultD'};

Norm=[VisCentMean VisPeriMean SomMotAMean SomMotBMean DorsAttnAMean DorsAttnBMean VentAttnMean SalMean LimbicMean ContAMean ContBMean ContCMean DefaultAMean DefaultBMean DefaultCMean DefaultDMean];

filename = [sub,'_DefaultD.txt'];
DefaultD = load(filename);
filename = [sub,'_DefaultC.txt'];
DefaultC = load(filename);
filename = [sub,'_DefaultB.txt'];
DefaultB = load(filename);
filename = [sub,'_DefaultA.txt'];
DefaultA = load(filename);
filename = [sub,'_ContC.txt'];
ContC = load(filename);
filename = [sub,'_ContB.txt'];
ContB = load(filename);
filename = [sub,'_ContA.txt'];
ContA = load(filename);
filename = [sub,'_Limbic.txt'];
Limbic = load(filename);
filename = [sub,'_Sal.txt'];
Sal = load(filename);
filename = [sub,'_VentAttn.txt'];
VentAttn = load(filename);
filename = [sub,'_DorsAttnB.txt'];
DorsAttnB = load(filename);
filename = [sub,'_DorsAttnA.txt'];
DorsAttnA = load(filename);
filename = [sub,'_SomMotB.txt'];
SomMotB = load(filename);
filename = [sub,'_SomMotA.txt'];
SomMotA = load(filename);
filename = [sub,'_VisPeri.txt'];
VisPeri = load(filename);
filename = [sub,'_VisCent.txt'];
VisCent = load(filename);

boxplot(Norm,'widths',0.3,'notch','on','orientation','horizontal','labels',names);
title('Within-network Mean Connectivity','FontSize',20);
xlabel('Z(r)');
hold on
nstats=[VisCent VisPeri SomMotA SomMotB DorsAttnA DorsAttnB VentAttn Sal Limbic ContA ContB ContC DefaultA DefaultB DefaultC DefaultD];
y=[1:16];
color=[ 0.4706 0.0706 0.5255; 0.4706 0.0706 0.5255; 0.2745 0.5098 0.7059; 0.2745 0.5098 0.7059; 0 0.4627 0.0549; 0 0.4627 0.0549; 0.7686 0.2275 0.9804; 0.7686 0.2275 0.9804; 0.8627 0.9725 0.6431; 0.9020 0.5804 0.1333; 0.9020 0.5804 0.1333; 0.9020 0.5804 0.1333; 0.8039 0.2431 0.3059; 0.8039 0.2431 0.3059; 0.8039 0.2431 0.3059; 0.8039 0.2431 0.3059 ];

for i=1:16
	scatter(nstats(i),y(i),'go','MarkerFaceColor',color(i,:),'MarkerEdgeColor','k','LineWidth',0.3,'SizeData',120);
end
print(gcf,[sub,'_boxplot.png'],'-dpng','-r600');
hold off
close all
exit
