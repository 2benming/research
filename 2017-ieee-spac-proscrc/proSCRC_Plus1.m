% proSCRC_Multi.m
% ProCRC �� SRC ���г˷��ں�
% - �ڱ�ʾϵ�����ںϣ��ο� SCRC.m

algName = 'ProSCRC_Multi';

[numOfAllTrains, sampleSize] = size(trainData); % number of all training samples
[numOfAllTests, sampleSize] = size(testData);   % number of all test samples
fprintf('numOfTrain=%d\tnumOfClasses=%d\tnumOfAllTests=%d\n', numOfTrain, numOfClasses,numOfAllTests);

%% ProCRC
addpath 'ProCRC';
addpath 'ProCRC/utilities';
%clear coefProCRC;
%clear labelProCRC;
data.tr_descr = trainData';
data.tr_label = trainLabel';
data.tt_descr = testData';
data.tt_label = testLabel';
params.dataset_name      =      dbName;
params.gamma             =      [1e-2];
params.lambda            =      [1e-0];
params.class_num         =      numOfClasses;
params.model_type        =      'R-ProCRC';
disp('ProCRC start ...');
coefProCRC = ProCRC(data, params); %
% TODO �ҳ���ʾϵ���ļ��㲽�裬�ٽ����ں�
%[labelProCRC, ~] = ProMax(coefProCRC, data, params);
pre_matrix = zeros(numOfClasses,numOfAllTests);
recon_tr_descr   = data.tr_descr * coefProCRC;
for ci = 1:numOfClasses
    loss_ci = recon_tr_descr - data.tr_descr(:, data.tr_label == ci) * coefProCRC(data.tr_label == ci,:);
    pci = sum(loss_ci.^2, 1);
    pre_matrix(ci,:) = pci;
end
% recognition
[~,labelProCRC] = min(pre_matrix,[],1);
errorsProCRC = 0;
for kk=1:numOfAllTests
    if labelProCRC(kk) ~= testLabel(kk,1)
        errorsProCRC=errorsProCRC+1;
    end
end
% save all deviations for ProCRC
deviationsProCRC = pre_matrix';
% result by ProCRC
accuracyProCRC = 1-errorsProCRC/numOfAllTests;

%% SRC
addpath 'SRC';
errorsSRC = 0;
clear testSample;
for kk=1:numOfAllTests
    testSample=testData(kk,:);
    % print progress ...
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    % SRC solution - �ж��ֽ��ʹ��
    [solutionSRC, total_iter] =    SolveFISTA(trainData',testSample');
    % compute contributions
    clear contributionSRC;
    for cc=1:numOfClasses
        contributionSRC(:,cc)=zeros(row*col,1);
        
        for tt=1:numOfTrain
            % C(i) = sum(S(i)*T)
            contributionSRC(:,cc)=contributionSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    % �������|�в�|����
    clear deviationSRC;
    for cc=1:numOfClasses
        % r(i) = |D(i)-C(i)|
        deviationSRC(cc)=norm(testSample'-contributionSRC(:,cc));
    end
    
    % ����ʶ����
    [min_value xxSRC]=min(deviationSRC);
    %labelSRC(kk)=xxSRC;
    labelSRC = xxSRC;
    if labelSRC ~= testLabel(kk,1)
        errorsSRC=errorsSRC+1;
    end
    
    % �������|�в�
    deviationsSRC(kk,:) = deviationSRC;
end
% ׼ȷ��
accuracySRC = 1-errorsSRC/numOfAllTests;

%% �ںϾ���
%lambdas = [-100,-50,-30,-10,1,10,30,50,100];
%lambdas = [1];
errorsSCRC=0; 
for kk=1:numOfAllTests
    testSample=testData(kk,:);
    [solutionSRC, total_iter] =    SolveFISTA(trainData',testSample');
    % compute contributions
    solutionProCRC = coefProCRC(:,kk);
    clear contributionSCRC;
    for cc=1:numOfClasses
        contributionSCRC(:,cc)=zeros(row*col,1);
        
        for tt=1:numOfTrain
            % C(i) = sum(S(i)*T)
            contributionSCRC(:,cc)=contributionSCRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*solutionProCRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    % �������|�в�|����
    clear deviationSCRC;
    for cc=1:numOfClasses
        % r(i) = |D(i)-C(i)|
        deviationSCRC(cc)=norm(testSample'-contributionSCRC(:,cc));
    end
    
    % ����ʶ����
    [min_value xxSCRC]=min(deviationSCRC);
    labelSCRC = xxSCRC;
    %[min_value xxSRC]=min(deviationSRC);
    %labelSRC(kk)=xxSRC;
    %labelSRC = xxSRC;
    if labelSCRC ~= testLabel(kk,1)
        errorsSCRC=errorsSCRC+1;
    end
    % ��������
    %if kk==63 break; end
end

% stats the error rates




errorsRatioSCRC = errorsSCRC/numOfAllTests;
accuracyFusion = 1 - errorsRatioSCRC;
fprintf('\nCRC=%.4f\tDL=%.4f\tFusion=%.4f\n', accuracyProCRC,accuracySRC,accuracyFusion);

% improvement
improve1 = (accuracyFusion-accuracySRC)*100/accuracySRC;
improve2 = (accuracyFusion-accuracyProCRC)*100/accuracyProCRC;

% save to json
jsonFile = [dbName '/' algName '_' num2str(numOfTrain) '_' num2str(accuracyFusion,'%.4f') '(' num2str(improve1,'%.1f') '%,' num2str(improve2,'%.1f') '%)'];
jsonFile = [jsonFile  '.json'];
results = [accuracyProCRC, accuracySRC, accuracyFusion,  trainIndices];
dbJson = savejson('', results, jsonFile);