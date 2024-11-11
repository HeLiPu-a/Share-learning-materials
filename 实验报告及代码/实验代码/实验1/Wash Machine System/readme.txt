

WashM=readfis('washmachine.fis'); %ģ�����Ƶ�ģ���Ѿ�������������������'washmachine.fis'�ļ��У�ͨ����readfis�������ȡ�������WashM������


% �����鱾��ģ�����ƹ����������9����Ӧ�Ĺ���
rule1="dust==SD & gas==NG => washtime=VS";
rule2="dust==SD & gas==MG => washtime=M";
rule3="dust==SD & gas==LG => washtime=L";
rule4="dust==MD & gas==NG => washtime=S";
rule5="dust==MD & gas==MG => washtime=M";
rule6="dust==MD & gas==LG => washtime=L";
rule7="dust==LD & gas==NG => washtime=M";
rule8="dust==LD & gas==MG => washtime=L";
rule9="dust==LD & gas==LG => washtime=VL";


% �á�addrule�����������9���������ӵ�washmachineģ����
WashM=addrule(WashM,rule9);
WashM=addrule(WashM,rule5);
WashM=addrule(WashM,rule1);

WashM=addrule(WashM,rule2);
WashM=addrule(WashM,rule3);
WashM=addrule(WashM,rule4);
WashM=addrule(WashM,rule6);
WashM=addrule(WashM,rule7);
WashM=addrule(WashM,rule8);

ruleview(WashM); %�á�ruleview������鿴��������Ľ�����ᵯ��GUI����

%��GUI�������·�input������[x y]����ʽ�����������֬����ֵ����[60 70],���Թ۲쵽���Ϸ���washtime������ֵ�ı仯��
%ͬ�������벻ͬ��[x y]��ֵ���۲�washtime�ı仯
%Ҳ������GUI��������dust �� gas��Ӧ�ĺ����ߣ��۲�washtime��ֵ�ı仯

%���view�˵���surface���鿴���۽������ͼ


writefis(WashM,'newwashmachine.fis');  %�����¸��ĺ��WashMģ�ͱ��浽�ļ�'newwashmachine.fis'��
fuzzy('newwashmachine.fis');  %������fuzzy�鿴��ģ��input��output�������������趨