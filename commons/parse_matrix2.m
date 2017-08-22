function parse_matrix2(indiv,SaveName)
I=load(indiv)

VisCent=I(1:2,1:2);
VisPeri=I(3:5,3:5);
SomMotA=I(6:7,6:7);
SomMotB=I(8:11,8:11);
DorsAttnA=I(12:14,12:14);
DorsAttnB=I(15:18,15:18);
VentAttnA=I(19:26,19:26);
Sal=I(27:31,27:31);
Limbic=I(32:33,32:33);
ContA=I(34:40,34:40);
ContB=I(41:45,41:45);
ContC=I(46:47,46:47);
DefaultA=I(48:53,48:53);
DefaultB=I(54:56,54:56);
DefaultC=I(57:59,57:59);
DefaultD=I(60:61,60:61); 

VisCentm=mean(VisCent);
VisPerim=mean(VisPeri);
SomMotAm=mean(SomMotA);
SomMotBm=mean(SomMotB);
DorsAttnAm=mean(DorsAttnA);
DorsAttnBm=mean(DorsAttnB);
VentAttnAm=mean(VentAttnA);
Salm=mean(Sal);
Limbicm=mean(Limbic);
ContAm=mean(ContA);
ContBm=mean(ContB);
ContCm=mean(ContC);
DefaultAm=mean(DefaultA);
DefaultBm=mean(DefaultB);
DefaultCm=mean(DefaultC);
DefaultDm=mean(DefaultD);

VisCent=mean(VisCentm);
VisPeri=mean(VisPerim);
SomMotA=mean(SomMotAm);
SomMotB=mean(SomMotBm);
DorsAttnA=mean(DorsAttnAm);
DorsAttnB=mean(DorsAttnBm);
VentAttnA=mean(VentAttnAm);
Sal=mean(Salm);
Limbic=mean(Limbicm);
ContA=mean(ContAm);
ContB=mean(ContBm);
ContC=mean(ContCm);
DefaultA=mean(DefaultAm);
DefaultB=mean(DefaultBm);
DefaultC=mean(DefaultCm);
DefaultD=mean(DefaultDm);

means={'VisCent',VisCent;'VisPeri',VisPeri;'SomMotA',SomMotA;'SomMotB',SomMotB;'DorsAttnA',DorsAttnA;'DorsAttnB',DorsAttnB;'VentAttnA',VentAttnA;'Sal',Sal;'Limbic',Limbic;'ContA',ContA;'ContB',ContB;'ContC',ContC;'DefaultA',DefaultA;'DefaultB',DefaultB;'DefaultC',DefaultC;'DefaultD',DefaultD};

cell2csv(SaveName,means)

