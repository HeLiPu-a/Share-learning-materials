putNoiseDigit = 0;  	%���Ҫ�ڽ�ҪԤ���ͼƬ���Զ�������㣬���� putNoiseDigit=1
toEditPredDigit = 0;  	%���Ҫ���ֶ��ڽ�ҪԤ���ͼƬ�ϻ��������� toEditPredDigit=1
toShowDigitTest = 1;  	%���Ҫ��ʾ����ͼƬ�����Ӧ���жϽ�������� toShowDigitTest = 1

%������������������Ϊͼ�����ݴ洢��imageDatastore �����ļ��������Զ����ͼ��
%�������ݴ洢Ϊ ImageDatastore ����ͨ��ͼ�����ݴ洢���Դ洢��ͼ�����ݣ�
%�����޷������ڴ�����ݣ����ھ���������ѵ�������и�Ч������ȡͼ��
digitDatasetPath = '.\';
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');
	
%��ʾ���ݴ洢�еĲ���ͼ��
figure;
perm = randperm(10000,20);
for i = 1:20
    subplot(4,5,i);
    imshow(imds.Files{perm(i)});
end


%����ÿ������е�ͼ��������labelCount ��һ���������г��˱�ǩ��
%�Լ�ÿ����ǩ��Ӧ��ͼ�����������ݴ洢�������� 0-9 ���ܹ� 10000 
%��ͼ��ÿ�����ֶ�Ӧ 1000 ��ͼ��
labelCount = countEachLabel(imds);

%������������������ָ��ͼ��Ĵ�С����� digitData �е�һ��ͼ��Ĵ�С��
%ÿ��ͼ��Ĵ�С��Ϊ 28��28��1 ���� ,dim=28

img = readimage(imds,1);
[~,dim] = size(img);


%�����ݻ���Ϊѵ�����ݼ�����֤���ݼ�����ʹѵ�����е�ÿ�������� numTrainFiles ��ͼ��
%������֤��������Ӧÿ����ǩ������ͼ��splitEachLabel �����ݴ洢 digitData 
%���Ϊ�����µ����ݴ洢 trainDigitData �� valDigitData��
numTrainFiles = 995;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');


%������������ܹ�
layers = [
    imageInputLayer([dim dim 1])    
	
    convolution2dLayer(4,1,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)    
    
    fullyConnectedLayer(size(labelCount,1))
    softmaxLayer
    classificationLayer];


% ָ��ѵ��ѡ�ʹ�þ��ж���������ݶ��½� (SGDM) ѵ�����磬��ʼѧϰ��Ϊ 0.01��
% �����ѵ����������Ϊ 1��һ��ѵ���Ƕ�����ѵ�����ݼ���һ������ѵ�����ڡ�
% ͨ��ָ����֤���ݺ���֤Ƶ�ʣ����ѵ�������е�����׼ȷ�ȡ�
% ÿ��ѵ������������ݡ��������ѵ������ѵ�����磬����ѵ�������а��̶�ʱ�������������֤���ݵ�׼ȷ�ȡ�
% ��֤���ݲ����ڸ�������Ȩ�ء���ѵ������ͼ���ر������д��������
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',2, ...
    'Verbose',true ,...,
    'Plots','training-progress');

%ʹ��ѵ������ѵ������
%�鿴ϵͳ��������
net = trainNetwork(imdsTrain,layers,options);	

save wrkspc.mat;
% load wrkspc.mat;


if toEditPredDigit==1
	% ͨ��OSϵͳС�������ͼƬ������
	% ע������ϵͳ��ʾ.�޸���ͼƬ��һ��Ҫʹ�á����Ϊ����������ͼƬ����������
	editPredFigures(imdsValidation);
end


% Ҫ�ڽ�ҪԤ���ͼƬ���Զ��������
if putNoiseDigit==1
	noiseNum=10;
	puttingNoiseInDigit(imdsValidation,noiseNum);
end


%ʹ�þ���ѵ��������Ԥ����֤���ݵı�ǩ��������������֤׼ȷ�ȡ�
%׼ȷ��������Ԥ����ȷ�ı�ǩ�ı�����
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;
accuracy = sum(YPred == YValidation)/numel(YValidation) *100;
disp(strcat('ϵͳ�ֱ�׼ȷ�ʴﵽ��',num2str(accuracy),'%'));

if toShowDigitTest==1
    close all;
    showList = randperm(length(imdsValidation.Files));
    disp('ͼƬ����ʾ������/�жϵ�����ͼƬ��ͼƬ�Ϸ������ֱ�ʾ�жϵĽ�������������ո�ʹ���л���');
    for i=1:length(imdsValidation.Files)
        imshow(imdsValidation.Files{showList(i)});
        title(YPred(i),'FontSize',24);
        pause;
    end
    close all
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �����ǵ��õĺ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function editPredFigures(imdsValidation)
    listToDraw = [7]; 			% ��Ҫ���ĵ�ͼƬ��imdsValidation.Files�е���ţ�listToDraw������һ���б�/����
	disp('�޸�ͼƬʱ�����ʹ�û�ͼ����Դ�����ɫѡȡ��������ɫ������������ѡ����');
	if any(listToDraw>length(imdsValidation.Files)) , error('wrong here');end
	for i=1:length(listToDraw)
		disp('�޸ĺ��ͼƬһ��Ҫ����������·�����ļ����ƣ���������:');
		filename = strcat(imdsValidation.Files{listToDraw(i)},'.123.png');
		disp(filename);		
		command=strcat('mspaint',32,imdsValidation.Files{listToDraw(i)});
		system(command);
		imdsValidation.Files{listToDraw(i)} = filename;
		a = imread(imdsValidation.Files{listToDraw(i)});
		a = a(:,:,1);
		filenameFinal = strcat(filename,'.tmp');
		imwrite(a,filenameFinal,'png');		
		imdsValidation.Files{listToDraw(i)}=filenameFinal;
		
		command = strcat('del',32,filename);
		system(command);
		
	end
end



function puttingNoiseInDigit(imdsValidation,noiseNum)
    for fileInd=1:length(imdsValidation.Files)
		a=imread(imdsValidation.Files{fileInd});
        c=a;
		[x,y]=find(a);
		listChangeIdn=randperm(length(x),noiseNum);
		for i=1:noiseNum
			done = 0;
			while ~done
				x1=x(listChangeIdn(i))+floor(randn*1);
				if (x1>28 || x1<1) continue; end
				y1=y(listChangeIdn(i))+floor(randn*1);
				if (y1>28 || y1<1) continue; end
				if(a(x1,y1)==0) 
					done=1;
				end
			end
			rv = randn*5;
			c(x1,y1) = c(x(listChangeIdn(i)),y(listChangeIdn(i)))+floor(rv);
			c(x1,y1) = max(0,c(x1,y1));
			c(x1,y1) = min(255,c(x1,y1));			
		end
		imwrite(c,strcat(imdsValidation.Files{fileInd},'.tmp'),'png');
		imdsValidation.Files{fileInd}=strcat(imdsValidation.Files{fileInd},'.tmp');
	end
end
