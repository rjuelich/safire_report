%=========================================================================
%

function PlotIndiv2Group(indiv,SaveName)

%Loads 2D matrix color tables
G=load('/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_NMR/GSP_CONS_n2642_1_BH_mean_corr_mat.txt');
I=load(indiv);

G0=reshape(G,[3721,1]);
I0=reshape(I,[3721,1]);

scatter(G0,I0,'filled','MarkerFaceColor',[ 0.8 0.8 0.8 ]);
set(gca, 'Xlim', [-0.5,1.5]);
set(gca, 'Ylim', [-0.5,1.5]);

R=corr2(G,I);
X=polyfit(G0,I0,1);
stats=[R X];
csvwrite([SaveName,'.csv'],stats);

text(-0.4,1.4,['R^2=',num2str(R*R)]);
text(-0.4,1.3,['A=',num2str(X(1))]);
text(-0.4,1.2,['B=',num2str(X(2))]);

hold on

Vis=I(1:5,1:5);
SomMot=I(6:11,6:11);
DorsAttn=I(12:18,12:18);
VentAttn=I(19:31,19:31);
Limb=I(32:33,32:33);
Cont=I(34:47,34:47);
DN=I(48:61,48:61);

G_Vis=G(1:5,1:5);
G_SomMot=G(6:11,6:11);
G_DorsAttn=G(12:18,12:18);
G_VentAttn=G(19:31,19:31);
G_Limb=G(32:33,32:33);
G_Cont=G(34:47,34:47);
G_DN=G(48:61,48:61);

%scatter(G_Vis(:),Vis(:),'filled','MarkerFaceColor',[ 0.4706 0.0706 0.5255],'MarkerEdgeColor','k');
%scatter(G_SomMot(:),SomMot(:),'filled','MarkerFaceColor',[ 0.2745 0.5098 0.7059 ],'MarkerEdgeColor','k');
%scatter(G_DorsAttn(:),DorsAttn(:),'filled','MarkerFaceColor',[ 0 0.4627 0.0549 ],'MarkerEdgeColor','k');
%scatter(G_VentAttn(:),VentAttn(:),'filled','MarkerFaceColor',[ 0.7686 0.2275 0.9804 ],'MarkerEdgeColor','k');
%scatter(G_Limb(:),Limb(:),'filled','MarkerFaceColor',[ 0.8627 0.9725 0.6431 ],'MarkerEdgeColor','k');
%scatter(G_Cont(:),Cont(:),'filled','MarkerFaceColor',[ 0.9020 0.5804 0.1333 ],'MarkerEdgeColor','k');
scatter(G_DN(:),DN(:),'filled','MarkerFaceColor',[0.8039 0.2431 0.3059 ]);
scatter(G_Vis(:),Vis(:),'filled','MarkerFaceColor',[ 0.4706 0.0706 0.5255]);
scatter(G_SomMot(:),SomMot(:),'filled','MarkerFaceColor',[ 0.2745 0.5098 0.7059 ]);
scatter(G_DorsAttn(:),DorsAttn(:),'filled','MarkerFaceColor',[ 0 0.4627 0.0549 ]);
scatter(G_VentAttn(:),VentAttn(:),'filled','MarkerFaceColor',[ 0.7686 0.2275 0.9804 ]);
scatter(G_Limb(:),Limb(:),'filled','MarkerFaceColor',[ 0.8627 0.9725 0.6431 ]);
scatter(G_Cont(:),Cont(:),'filled','MarkerFaceColor',[ 0.9020 0.5804 0.1333 ]);
scatter(G_DN(:),DN(:),'filled','MarkerFaceColor',[0.8039 0.2431 0.3059 ]);
set(gca, 'Xlim', [-0.5,1.5]);
set(gca, 'Ylim', [-0.5,1.5]);

fplot(@(x)X(1)*x+X(2),[-0.5,1.5],'k--');
fplot(@(x)x,[-0.5,1.5],'k:');
title('Individual vs Canonical Group Connectivity','FontSize',24);
ylabel('Individual Z(r)','FontSize',24);
xlabel('Group Z(r) [n=2642]','FontSize',24);
%Save figures
print(gcf,[SaveName,'.png'],'-dpng','-r900');
close all;
