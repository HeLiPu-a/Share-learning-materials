function gatsp()
	hold off
	nc = 20;		% ���еĸ���
	N = 100;		% Ⱦɫ��Ⱥ���ģ
	MAXITER = 100000;	% ���ѭ������
	SelfAdj = 0; 	%SelfAdj = 1ʱΪ����Ӧ
    
	pc = 0.85;		% �������
	pw = 0.15;		% �������
	
	locationx=floor(rand(nc,1)*100);
	locationy=floor(rand(nc,1)*100);
	locations=[locationx,locationy];
    %load locations10.mat;
    load locations20.mat;
    %load locations100.mat;
	R = distCal(locations);
    
	
	% ����1������N��Ⱦɫ��ĳ�ʼȺ��,������pop����
	pop = initPop(N,nc);
	
	iter=0;
    tstart=clock;
	while iter<MAXITER
        iter = iter+1;
		trajLength=calLen(pop,R);				%����2������ÿ��Ⱦɫ���·������		
		fitness=calFitness(trajLength);			%      ����ÿ��Ⱦɫ�����Ӧֵ	%������Ҫ��д
        [b,f,ind]=findBest(pop,fitness);
		if satified(fitness), break; end		%����3���������ĳЩ��׼���㷨ֹͣ		
		pop = chooseNewP(pop,fitness);			%      ����ѡȡ��һ���µ�Ⱥ��	%������Ҫ��д
		pop = crossPop(pop,pc,fitness,SelfAdj);	%����4�����������Ⱦɫ�壬�õ���Ⱥ�� %������Ҫ��д		
		pop = mutPop(pop,pw,fitness,SelfAdj); 	%����5���������	%������Ҫ��д
		pop(1,:) = b(1,:);						% ������һ������Ӧֵ��ߵ�Ⱦɫ��             
    end	    
	
	%�������Ⱦɫ��/·��
	disp(strcat('���ŵ�·������Ϊ��',num2str(calLen(b(1,:),R)),'����ӦֵΪ��',num2str(f),'����Ӧ��·��Ϊ��'));
	disp(b(1,:));			
    
	%��������ʱ��
    tend=clock;
	disp(strcat('The program need : ',num2str(etime(tend,tstart)),' seconds.'));
	
	%��ʾ����·��ͼ��
	drawTSP(locations, b(1,:));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ݸ����е�location�������������
% ��ľ������R
function R = distCal(location)
	nc=size(location,1);
	R = zeros(nc);
	for i=1:nc
		for j=i+1:nc
			R(i,j) = sqrt(sum((location(i,:)-location(j,:)).^2));
		end
	end
	R = R+R';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����N��Ⱦɫ��ĳ�ʼȺ��,������pop��
% ÿ��Ⱦɫ�����TSP�����ĳһ���⣨�����г��ж�����һ�εĹ켣��
function pop=initPop(N,nc)
	pop = zeros(N,nc);
	for i=1:N,pop(i,2:end) = randperm(nc-1)+1;end %ʹ�������������N��Ⱦɫ��
	pop(:,1)=ones(N,1);  %����Ⱦɫ�嶼�ӳ���1��ʼ�����ص�����1.
end	



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���ݾ������R ������pop��ÿ��Ⱦɫ��������Ĺ켣�ĳ���
function trajLength = calLen(pop,R)
	[N,nc]=size(pop);
    trajLength = zeros(1,N);
	for i=1:N
		f=0;
		traj = pop(i,:);
		traj_2 = [traj(2:end),traj(1)];
		for j=1:nc 
            f = f+R(traj(j),traj_2(j)); 
        end
		trajLength(i) = f;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��������Ⱦɫ��ֱ�Ĺ켣���ȣ��������Ⱦɫ�����Ӧֵ
% trajLength	: ����Ⱦɫ��Ĺ켣����
% fitness		������Ⱦɫ�����Ӧֵ
function fitness=calFitness(trajLength)  %������Ҫ��д
%      fitness = size(1,length(trajLength));
    fitness = 1./trajLength; %s��Ӧ����1
%      fitness = 1000*(1./trajLength).^2; %s��Ӧ����2
    sum=0;
    a=5;
    sortlength =sort(trajLength);
    for j=1:a
        sum = sum + sortlength(j);
    end
    avgtrajL = sum/a;
    for i=1:length(trajLength)
        if trajLength(i)>avgtrajL
            fitness(i) = (1/trajLength(i))^10;
        else
            fitness(i) = trajLength(i)^10;
        end
    end
end

function fitvalue=calfitvalue(objvalue)

[px,py]=size(objvalue);                   %Ŀ��ֵ�����и�
for i=1:px
        if objvalue(i)>0                    
                temp=objvalue(i);          
        else
                temp=0.0;
        end
        fitvalue(i)=temp;
end
fitvalue=fitvalue';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����Ⱦɫ�����Ӧֵ������һ���ĸ��ʣ�������һ��Ⱦɫ��Ⱥ��
% pop		������Ⱦɫ��Ⱥ�壬 N x nc�ľ���
% fitness	����Ⱦɫ�����Ӧֵ������ΪN������
% newpop	�������µ�Ⱦɫ��Ⱥ�壬N x nc�ľ���
function newpop = chooseNewP(pop,fitness)	%������Ҫ��д
	[N,nc] = size(pop);
    newpop = zeros(N,nc);
    k = 1;
    gailv = size(1,length(fitness));
    sumfitness = sum(fitness);
    for p=1:length(fitness)     %��Ӧ����́0�2
        gailv(p) = fitness(p)/sumfitness;%�������Ӧ��������Ӧ�������ռ����Ϊ����
    end
    for i = 1:length(fitness)
        r = rand(1,1); 
        m = 0;
        for j=1:length(fitness)
            m = m + gailv(j);
            if m >= r
                newpop(k,:) = pop(j,:);
                k = k+1;
                break;
            end
        end
    end
    k = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ݽ������pc���Լ���Ⱦɫ�����Ӧֵfitness��ͨ������ķ�ʽ������Ⱥ��
% SelfAdj = 1ʱΪ����Ӧ������ȡ�̶��Ľ������pc
% pop		������Ⱦɫ��Ⱥ�壬 N x nc�ľ���
% fitness	����Ⱦɫ�����Ӧֵ������ΪN������
% cpop		�������µ�Ⱦɫ��Ⱥ�壬N x nc�ľ���
% pc		: �������
function cpop = crossPop(pop,pc,fitness,SelfAdj) %������Ҫ��д	
	[aa,bb] = size(pop);
    cpop = zeros(aa,bb);
    for l=1:2:length(fitness)
         r = rand(1,1);
        if pc >= r
            if l == length(fitness) && mod(l,2) == 1 
                cpop(l,:) = pop(l,:);
                break; 
            end
            qian2 = pop(l+1,:);
            qian1 = pop(l,:);
            [hou1,hou2] = genecross(qian1,qian2); 
            cpop(l,:) = hou1;
            cpop(l+1,:) = hou2;
        else
            cpop(l+1,:) = pop(l+1,:);
            cpop(l,:)= pop(l,:)
        end
    end
% 	[child1,child2] = genecross(partner1,partner2); %���genecross�������ܻ�����
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��Ⱦɫ��partner1,partner2��ͨ�����淽ʽ
% ����������Ⱦɫ��child1,child2
% partner1/2	: ����ǰ������Ⱦɫ��
% child1/2		������������Ⱦɫ��
function [child1,child2] = genecross(partner1,partner2)
	len = length(partner1);
	idx1 = randi(len-1)+1;
	idx2 = randi(len-1)+1;
	ind1 = min(idx1,idx2);
	ind2 = max(idx1,idx2);
	
	child1 = partner1;
	child2 = partner2;
	
	tem1 = child1(ind1:ind2);
	tem2 = child2(ind1:ind2);	
	
	temdff1 = setdiff(tem1,tem2);
	temdff2 = setdiff(tem2,tem1);	

	for i=1:length(temdff1)
		child1(find(child1==temdff2(i)))=temdff1(i);
		child2(find(child2==temdff1(i)))=temdff2(i);		
	end	
	
	child1(ind1:ind2) = tem2;
	child2(ind1:ind2) = tem1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ݱ������pw���Լ���Ⱦɫ�����Ӧֵfitness��ͨ������ķ�ʽ������Ⱥ��
% %SelfAdj = 1ʱΪ����Ӧ������ȡ�̶��ı������pw
% pop		������Ⱦɫ��Ⱥ�壬 N x nc�ľ���
% fitness	����Ⱦɫ�����Ӧֵ������ΪN������
% mpop		�������µ�Ⱦɫ��Ⱥ�壬N x nc�ľ���
% pw		: �������
function mpop = mutPop(pop,pw,fitness,SelfAdj) %������Ҫ��д
	[n,Mc]=size(pop);
%     disp('pop�0�2N');
%     disp(n);
%     disp('pop�0�2nc');
     disp(Mc);
    for j=1:n
        r = rand(1,1);
        if pw <= r
            mpop(j,:) = genebianyi(pop(j,:));
        else
            mpop(j,:) = pop(j,:);
        end
    end  
end
    function child1 = genebianyi(partner1) %��������
        len = length(partner1);
        idx1 = randi(len-1)+1;
        idx2 = randi(len-1)+1;
        idx3 = randi(len-3)+2;
        r = rand(1,1);
        ind1 = min(idx1,idx2);
        ind2 = max(idx1,idx2); 
        child1 = partner1;
        tem1 = child1(ind1);
        tem2 = child1(ind2);
        child1(ind2) = tem1;     %��������0�2
        child1(ind1) = tem2;
         tem3 = child1(idx3);     %�ƶ�����
%          if 0.5 >= r 
%               child1(idx3) = child1(idx3 +1);
%               child1(idx3 +1) = tem3;
%          else
%              child1(idx3) = child1(idx3 -1);
%               child1(idx3 -1) = tem3;
%          end
%          for i=ind1:ind2          %�������
%              tem4(i-ind1+1) = child1(i); 
%          end
%          for i=1:ind2-ind1
%             child1(ind2-i+1) = tem4(i);
%          end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����Ⱦɫ��Ⱥ��pop�Ѿ���Ӧ����Ӧֵfitness��
% �ҵ���ߵ���Ӧֵf���Լ���Ӧ��Ⱦɫ��bst������pop�еı��/�±�ind
function [bst,f,ind] = findBest(pop,fitness) 
    f = max(fitness);
	ind = find(fitness == f);
	bst = pop(ind,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �������е�ĳ��״̬������ĳЩ��׼����ֹͣ���С�
% �ڵ�ǰ�����£������þ���ֹͣ��׼�����Է���sat=0
function [sat]=satified(fitness)
	sat=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����Ⱦɫ��traj���涨�Ĺ켣���Լ������е�λ��locations�������ù켣
function drawTSP(locations, traj)
	nc = size(locations, 1);
	plot(0,0,'.'); hold on; plot(100,100,'.');
	for i = 1:nc
		indP = traj(i);
		strPx = locations(traj(i), 1);
		strPy = locations(traj(i), 2);
		endPx = locations(traj(mod(i,nc)+1), 1);
		endPy = locations(traj(mod(i,nc)+1), 2);		
		plot([strPx,endPx],[strPy,endPy],'ms-','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g');
		text(strPx,strPy,['  ', int2str(indP)]);		
    end
end
