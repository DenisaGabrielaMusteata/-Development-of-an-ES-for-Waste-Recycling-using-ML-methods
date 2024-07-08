
clear all
close all
clc

%dim 227x227 resize
%% Parametri

% set date
pathImages="C:\Users\muste\Desktop\Proiect-SBC\TrainData";
        %imagini RGB 227 x 227

% nume fisier rezultate

nameFileRez='rez1';

%testez pt val hann
% antrenare
MBS=50; %mini-batch %25, 75 
NoEp=100; %nr epoci %100, 150, 250


%% Copiere imagini in director
% unzip('MerchData.zip'); 
 
%% Creare baza de date cu imagini RGB pentru antrenare, valiadre testare
imds = imageDatastore(pathImages, ...  
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames'); 
 
[imdsTrain,imdsValidation, imdsTest] = splitEachLabel(imds,0.8,0.10,0.10,'randomized'); 

numTrainImages = numel(imdsTrain.Files); 
numClasses = numel(categories(imdsTrain.Labels));

im=readimage(imdsTrain,1); inputSize = size(im); 

%% Extindere set date de antrenare       
pixelRange = [-30 30];   
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

%% Incarcare model alexnet pre-antrenat 
net = alexnet; 

%% Constructie arhitectura model nou cu "transfer learning": layers

% straturi importate
layersTransfer = net.Layers(1:end-3); 

% model nou
layers = [
    layersTransfer   
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20) % ponderi initializate cu valori aletoare
    softmaxLayer 
    classificationLayer]; 

%% Antrenare retea

% setare parametri pentru antrenare
options = trainingOptions('sgdm', ...
    'MiniBatchSize',MBS,...            
    'MaxEpochs',NoEp, ...      
    'InitialLearnRate',1e-4, ...  
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',3, ...
    'ValidationPatience',Inf, ...
    'Verbose',false, ...
    'Plots','training-progress');
                  
% antrenare CNN
netTransfer = trainNetwork(imdsTrain,layers,options);
nameFileRez = [nameFileRez, '_', num2str(MBS), '_', num2str(NoEp), '.mat'];
% salvare model
feval(@save,nameFileRez,'netTransfer'); 


%% Verificare rezultate dupa antrenare - pentru setul de antrenare/validare/testare 
[YPredValidation,scoresValidation] = classify(netTransfer,imdsValidation);  % obtine raspunsul retelei 
accuracyValidation = mean(YPredValidation == imdsValidation.Labels)  % calculeaza acuratetea
 
[YPredTrain,scoresTrain] = classify(netTransfer,imdsTrain); 
accuracyTrain = mean(YPredTrain == imdsTrain.Labels)  

[YPredTest,scoresTest] = classify(netTransfer,imdsTest);  
accuracyTest = mean(YPredTest == imdsTest.Labels)  
 
% % Afisare imagini gresit clasificate - validare
% j=0;rf=5;cf=5;
% for i=1:numel(YPredValidation)
%     if YPredValidation(i)~=imdsValidation.Labels(i)
%          I = readimage(imdsValidation,i);
%          j=j+1;
%          if j==(rf*cf+1), j=1; end
%          if j==1, figure; end
%          subplot(rf,cf,j); imshow(I);
%          title(['target: ', string(imdsValidation.Labels(i)), ' obtained: ', string(YPredValidation(i))]);
%     end
% end
% 
% 
% % Vizualizare harti trasaturi (optional)
% im=readimage(imdsTrain,5);
%     %selLayers={'conv1','pool1', 'conv2', 'pool2','conv3','conv4','conv5'};
%     %selLayers={'pool1', 'pool2','conv3','conv4','conv5'};
%     %selLayers={'conv5','pool5'};
% selLayers={'pool1'};
% rf=5;cf=5;features=[];
% for i=1:numel(selLayers)
%     features{i} = activations(netTransfer,im,selLayers{i});
%     k=1;
%     for j=1:size(features{i},3)
%         if k==(rf*cf+1), k=1; end
%         if k==1, figure; end
%         subplot(rf,cf,k),imshow(features{i}(:,:,j),[]); 
%         k=k+1;
%     end
% end


%%
