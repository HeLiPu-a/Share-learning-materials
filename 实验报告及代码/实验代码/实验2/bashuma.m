function []=bashuma  
	clear
	close all;
	
	nosDim = 4; 	% ��Ϸ����ά�ȣ�������ά��3��15����ά��4
	showPlot = 1; 	% 1,��ʾ������Ϸ����ƶ����̣�0������ʾ
	MAXITER = 10^10; %���ѭ������
	
	%%%%%%%%%%%%%%%%%%%%%%%
	% ���ݽṹ
	node.pre=zeros(nosDim);  	%%%���ڵ�״̬
	node.con=zeros(nosDim);		% �ڵ��״̬�����������˳��
	node.id = 0;				% �ڵ��Լ���id��, ��ýڵ㱣����NODES�����е��±�һ��
	node.father = 0;   			% ���ڵ��id��,Ψһ
	node.children =[];			% �ӽڵ��id�ţ������ж��
	node.g=0;   				%%%��ǰ״̬��g(n)��ֵ 
	node.h=0; 					%%%��ǰ״̬��h(n)��ֵ 
	node.cost= 0;  				%%%��ǰ״̬��f(n)��ֵ 
	% 
	%%%%%%%%%%%%%%%%%%%%%%%%
	NODES=repmat(node,1,10^4);
	
	iter=0;  %ѭ����������  
	
	nosSinOL=0; % openList ����״̬������
	nosSinCL=0; % closeList ����״̬������
	
	
	%��ʼ��  
	dis=reshape([1:nosDim^2]-1,nosDim,nosDim); 					%Ŀ��״̬
	initMatrix = reshape(randperm(nosDim^2)-1,nosDim,nosDim);  	%��ʼ״̬
	% initMatrix(:) = [ 4     1     3     0     8     5     7     6     2]; %tough init
	%initMatrix(:) = [ 8     1     0     5     7     2     6     3     4]; %tough init	 
	initMatrix(:) = [ 7 4 9 6 3 12 14 10 2 5 0  15 11 13 1 8];  %easy init	
	disp('��ʼ״̬��');
	disp(initMatrix);	
	disp('~~~~~~~~~');

	N.pre=zeros(nosDim);  %%%����״̬
	N.con=initMatrix;		% �ڵ��״̬�����������˳��
	N.id = 1;				% �ڵ��Լ���id��, ��ýڵ㱣����NODES�����е��±�һ��
	N.father = 0;   		% ���ڵ��id��,Ψһ
	N.children =[];			% �ӽڵ��id�ţ������ж��
	N.g=0;   				%%%��ǰ״̬��g(n)��ֵ 
	N.h=calH(N,dis); 		%%%��ǰ״̬��h(n)��ֵ 
	N.cost= N.g + N.h;  	%%%��ǰ״̬��f(n)��ֵ 
	
	NODES(1)=N;
	openList(1)=N.id; %��ʼ��openList��  %�鱾����1���鱾����2��ʡ�ԣ�
	
	if ~avlbSol(N,dis)
		disp('doesnot exist solution. ERROR.');
		return;
	end
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% ��ʼ����
	%
	tstart=clock;
	indexMin=0;
	y=dis;  
	while 1  
		%����ѭ������  
		iter=iter+1;  
		if iter==10^2,disp('iter==10^2');end
		if iter==10^3,disp('iter==10^3');end
		if iter==2*10^3,disp('iter==2*10^3');end
		if iter==5*10^3,disp('iter==5*10^3');end
		if iter==10^4,disp('iter==10^4');end
		if iter==10^5,disp('iter==10^5');end
		if iter==MAXITER  
			disp('too many loops, ERROR!!');  
			return;  
		end  	
		
		nosSinOL = length(openList);

		%  Ѱ��openList���д�����Сֵ  
		for j=1:nosSinOL  
			if N.cost>NODES(openList(j)).cost  
				N=NODES(openList(j));  
				indexMin = j;
			end  
		end  

		%%�Ѹ�״̬����� closeList ��  
		nosSinCL = nosSinCL+1;
		closeList(nosSinCL)=N.id;   %%%�鱾����3

		%%�Ѹ�״̬�� openList ����ɾ��  
		if length(openList)== 1 	%openList ��ֻ��һ��Ԫ��
			openList=[];
		else 						%openList ���ж��Ԫ��
			if indexMin~=nosSinOL	%���Ҫɾ����Ԫ�ز������һ��Ԫ�أ�������Ԫ����Ҫɾ��Ԫ��λ�öԻ�
				openList(indexMin) = openList(nosSinOL);
			end
			openList=openList([1:nosSinOL-1]);
		end

		%%�Ƿ��ҵ�Ŀ�Ľڵ�  %%%�鱾����4
		if goal(N,dis)  
			disp('success!!');  
			break;  
		end  

		%%��չ�ڵ�  %%%�鱾����5/6
		[NODES,openList,closeList]=moveSpace(NODES,openList,closeList,N,dis);  
		N.cost=inf; %%%��ʼ��k.fuc��ֵ������Ƚ�
        
        NODES=reflashValue(NODES,length(openList)+length(closeList)); %����ÿ���ڵ� g/h/cost��ֵ
	end  	
	tend=clock;
	%
	% ��������
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	disp(strcat('The program need : ',num2str(etime(tend,tstart)),' seconds.'));
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% ���·��
	%
	s = N;
	indexList=[];
	while 1
		indexList=[s.id,indexList];
		if s.id == 1; break; end
		if sum(sum(s.con~=NODES(s.father).con))~=2
			disp('strange here');
		end
		s = NODES(s.father);
	end
	
	
	disp('----1-----');
	disp(strcat('length of indexList is:',num2str(length(indexList))));
	disp(strcat('length of openList  is:',num2str(length(openList))));
	disp(strcat('length of closeList is:',num2str(length(closeList))));
	if showPlot==1
		for j=1:length(indexList)  
			plotbubbles(NODES(indexList(j)).con);
			title(num2str(j));
			pause(1);
		end  	
	end
	%
	% �������
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end  

%��ѯ�Ƿ��ҵ�Ŀ��ڵ�  
function ok=goal(N,dis)  
	ok=(N.con==dis);
end  

function flag=avlbSol(node,dis) %�ж��Ƿ���ڽ�
	con=node.con;	
	con=con';
	dis=dis';
	nosNXDcon = nixudui(con(:));
	nosNXDdis = nixudui(dis(:));
    if mod(nosNXDcon,2)==mod(nosNXDdis,2),flag=1;  %���ڽ�
    else, flag=0;
    end
end
function nos=nixudui(list)
	list(list==0)=[];
	len = length(list);
	nos=0;
	for i=1:len
		index = find(list==i);
		nos = nos+index-1;
		list(list==i)=[];
	end
end


function NODES=reflashValue(NODES,nosNodes)
    refFlag=1;
    while refFlag == 1
        refFlag=0;
        for i=2:nosNodes
            if NODES(i).g ~= NODES(NODES(i).father).g+1
                NODES(i).g = NODES(NODES(i).father).g+1;
                NODES(i).cost = NODES(i).g +NODES(i).h;
                refFlag=1;
            end
        end        
    end
end





