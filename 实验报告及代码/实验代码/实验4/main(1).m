function main()
	
	% ׼������ input/target
	% input �Ǹ� 63 x nosDigits �ľ��� ÿһ����һ������ͼƬ���������� 
	% target �Ǹ� nosDigits x nosDigits �ĶԽ��߾��󣬶Խ����϶���1 �� ÿ�ж�Ӧһ������ͼƬ����Ӧ��������ж����ĸ�����
	nosDigits=2; 		% ��Ҫʶ���������������
	[img]=loadimages(); % �ѱ�����loadimages.m�ļ����������ͼƬ��ȡ����	
	for i=1:nosDigits
		imgdgt = img(:,:,i); 
		input(:,i)=imgdgt(:); 		%������ͼƬ�������Ϊ����
	end
	target=diag(ones(nosDigits,1)); % 
	
	
	%%%%%%%%%%%%%%%
	% ����ϵͳ����
	toShowTestPredPlot=0;		%��ʾ���Թ�����ͼƬ�ıȽ�
	trainIter =1e4;	  			%ѵ����������
	testLength=1e2;				%������������
	nhidden=3;					%��������Ԫ����Ԫ����
	ninr = length(input(:,1));	%�����������Ԫ�����������ݱ��������
	nout = length(target(:,1));	%�����������Ԫ�����������ݱ��������
	learningRate=1e-2;			%����ѧϰ����
	nosChg10 = 3; 				%����ʱ��ÿ��ͼƬ�������Ѱ��nosChg10��������1���ظ�Ϊ0
	nosChg01 = 3;				%����ʱ��ÿ��ͼƬ�������Ѱ��nosChg01��������0���ظ�Ϊ1
	stage=[2:10]*trainIter/10;	%��ѵ���ֳɶ�������Ľ׶Σ�������ÿ��ѵ���׶ν���֮�����һ�β��ԣ����Ա�۲����error�Ƿ���ϸ��׶ν��ͣ�
	%
	%%%%%%%%%%%%%%%
	
	
	% �������磬������net
	net=createNet(ninr, nout, nhidden,learningRate);
    
    
    % ��ʼ��
	errTrain=zeros(trainIter,1);				%����ѵ�������е�error
	errTest=zeros(length(stage),testLength);	%�����ڲ��Թ����е�error
	
	iter = 0;
	for k = 1:length(stage) 		%�ֶ�������Ľ׶ν׶Σ�
	
		%%%%%%%%%%%%%%%%%%%%%%%%%
		% ��ʼѵ��
		while iter<stage(k)
			iter = iter +1 ;
			% ÿ��ѵ�������ѡȡѵ����������������ͼƬ����Ӧ�����
			if rand>0.5,trainInput=input(:,1); trainTarg=target(:,1);	%ѡȡ��1��������Ϊѵ������
			else, trainInput=input(:,2); trainTarg=target(:,2);			%ѡȡ��2��������Ϊѵ������
			end
			% ѵ������������磬������net
			[net,error]=netTrain(net,trainInput,trainTarg);
			% ��¼ѵ��error
			errTrain(iter) = mean(abs(error));
		end
		errTrn1000 = mean(errTrain(iter-1000:iter));
		
		%%%%%%%%%%%%%%%%%%%%%%%%%
		% ��ʼ����
		for i=1:testLength
			% ÿ��ѵ�������ѡȡ������������������ͼƬ����Ӧ�����
			if rand>0.5,testInput=input(:,1); testTarg=target(:,1); 	% ѡȡ��1��������Ϊ��������
			else testInput=input(:,2); testTarg=target(:,2);			% ѡȡ��2��������Ϊ��������
			end
			
			% ��ͼƬ�м�������/����
			testInput_backup = testInput; 		%�����ۼ�
			testInput = putNoiseInImg(testInput,nosChg10,nosChg01);
			 
			% ʹ�ø��ź�Ĳ���������ִ�����磬���output,���������Error
			[testOutput] = netTest(net,testInput,1);
			errTest(k,i) = mean(abs(testOutput-testTarg));	
			
			if toShowTestPredPlot==1
				showTestPredPlot(testInput,testOutput,input,target,testInput_backup);
			end 		
		end
		
		errTestMean = mean(errTest(k,:) );
		
		disp('------------');
		disp(strcat('��ϵͳ��ѵ�� ',num2str(iter),'�κ�'));
		disp(strcat('errTrn1000(���1000��ѵ��Error��ֵ)Ϊ��',num2str(errTrn1000)));
		disp(strcat('errTestMean(����Error��ֵ)Ϊ��',num2str(errTestMean)));
	end
	% ��ʾѵ���Ͳ��Թ��̵�error .
	figure (2),plot(errTrain(:)); title('Train Error');grid
	figure (1),plot(errTest(:));title('Test Error');grid; 
end


function showTestPredPlot(testInput,testOutput,input,target,testInput_backup)
	[~,nosDigits] = size(target);
	v=mean(abs(repmat(testOutput,1,nosDigits)-target),1);
	[~,ind]=min(v);
	figure(1),
	subplot(1,3,1),plotNum(testInput_backup);title('�����Ĳ���ͼƬ');
	subplot(1,3,2),plotNum(testInput);title('���ŵĲ���ͼƬ');
	subplot(1,3,3),plotNum(input(:,ind));title('�ж���Ŀ��ͼƬ');
	pause;
	subplot(1,1,1);
end
				
function inputImg = putNoiseInImg(inputImg,nosChg10,nosChg01)
	% ��ͼƬ�в��ֵ�1�ĳ�0���ı���ĿΪ nosChg10
	list=find(inputImg==1);
	nl=length(list);
	listChg10 = randperm(nl);
	listChg10 = listChg10(1:nosChg10);
	inputImg(list(listChg10))=0;		
	% ��ͼƬ�в��ֵ�0�ĳ�1���ı���ĿΪ nosChg01
	list=find(inputImg==0);
	nl=length(list);
	listChg01 = randperm(nl);
	listChg01 = listChg01(1:nosChg01);
	inputImg(list(listChg01))=1;	
end


function net=createNet(ninr, nout, nhidden,learningRate)
	net.ninr = ninr;
	net.nout = nout;
	net.nhidden = nhidden;

	net.hidfn = 'sigmoid'; 
	net.outfn = 'sigmoid';

	% initial weight matrix
	noiseLevel=0.1;
	net.win = randn(nhidden,ninr)*noiseLevel;
	net.wout = randn(nout,nhidden)*noiseLevel;
	
	net.lr = learningRate; %learning rate
end


function [net,Verror]=netTrain(net,input,target)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% forward
	[outState,hidState]=netTest(net,input,1);
	net.err = outState-target;
    Verror = net.err;
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% backward
	if strcmp(net.outfn,'sigmoid')==1
		dm = outState.*(1-outState).*net.err;
	else
		error('other output functions has not beed done yet, pls complete here.');	
	end		
	if strcmp(net.hidfn,'sigmoid')==1
		dk = hidState.*(1-hidState).*(dm'*net.wout)';
	else
		error('other hidden functions has not beed done yet, pls complete here.');	
	end		
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%����������
	aWout = - net.lr*dm*hidState';
	aWin  = - net.lr*dk*input';
	
	%�����������
	net.wout = net.wout + aWout;
	net.win = net.win + aWin;
end



function [outState,hidState]=netTest(net,input,future)
	netin = net.win*input;
	if strcmp(net.hidfn,'tanh')==1
		hidState = tanh(netin);
	elseif strcmp(net.hidfn,'sigmoid')==1
        hidState = 1./(1+exp(-netin));    
	elseif strcmp(net.hidfn,'linear')==1
		hidState = netin;
	else
		error('no such hidden function')	
	end
	
	netout = net.wout*hidState;
	if strcmp(net.outfn,'tanh')==1
		outState = tanh(netout);
	elseif strcmp(net.outfn,'sigmoid')==1
        outState = 1./(1+exp(-netout));    
	elseif strcmp(net.outfn,'linear')==1
		outState = netout;
	else
		error('no such output function')	
	end
end
