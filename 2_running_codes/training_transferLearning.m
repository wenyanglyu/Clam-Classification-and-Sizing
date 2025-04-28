clc;
clear variables;
close all;

% 1. Path Management
SourceDir = 'D:/Clam_Classify_Sizing/';  % Modify as needed
saveDir = fullfile(SourceDir, '4_saved_files');  % Save folder for all files
addpath(genpath(fullfile(SourceDir, '3_functions')));  % Add functions to path
addpath(saveDir);

modelFile = fullfile(saveDir, 'net_resFT_Final.mat');
origDir = fullfile(SourceDir, '1_images', '4_dataset');

% 2. Check if the model file exists
if isfile(modelFile)
    % 2.1 Load the saved model
    loadedData = load(modelFile);
    net = loadedData.net_resFT;
    modifyLayers = false; % Do not modify layers if loading from saved model
    disp("Trained model loaded.");
else
    % 2.2 Load pretrained ResNet-50
    net = resnet50;
    modifyLayers = true; % Modify layers if loading from pretrained model
    disp("No trained model found.");
end

% 3. Load Data
imds = imageDatastore(origDir, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

% 4. Display Random Data
numImages = numel(imds.Labels);
idx = randperm(numImages, 16);
I = imtile(imds, 'Frames', idx);
% figure
% imshow(I)

% 5. Prepare Dataset, Split Dataset Sequentially
classNames = categories(imds.Labels);
numClasses = numel(classNames);
[imdsTrain, imdsValidation, imdsTest] = splitEachLabel(imds, 0.7, 0.15);

% 5.1 Display Count of Each Label
countEachLabel(imdsTrain)
countEachLabel(imdsValidation)
countEachLabel(imdsTest)

% 6. Modify the Network if Required
if modifyLayers
    % 6.1 Modify the network by keeping all layers except the last three layers
    lgraph = layerGraph(net);

    % 6.2 Remove the last three layers (fully connected, softmax, classification)
    lgraph = removeLayers(lgraph, {'fc1000', 'fc1000_softmax', 'ClassificationLayer_fc1000'});

    % 6.3 Add new fully connected layer, dropout layer, softmax layer, and classification layer
    newFcLayer = fullyConnectedLayer(numClasses, 'Name', 'new_fc', 'WeightLearnRateFactor', 1, 'BiasLearnRateFactor', 1);
    newDropoutLayer = dropoutLayer(0.3, 'Name', 'new_dropout');
    newSoftmaxLayer = softmaxLayer('Name', 'new_softmax');
    newClassificationLayer = classificationLayer('Name', 'new_classoutput');

    % 6.4 Add the new layers to the layer graph
    lgraph = addLayers(lgraph, newFcLayer);
    lgraph = addLayers(lgraph, newDropoutLayer);
    lgraph = addLayers(lgraph, newSoftmaxLayer);

    % 6.5 Connect the new layers to the network
    lgraph = connectLayers(lgraph, 'avg_pool', 'new_fc');
    lgraph = connectLayers(lgraph, 'new_fc', 'new_dropout');
    lgraph = connectLayers(lgraph, 'new_dropout', 'new_softmax');

    % 6.6 Convert layerGraph to dlnetwork
    netTransfer = dlnetwork(lgraph);

    % 6.7 Freeze the initial layers using the provided function
    netTransfer = freezeNetwork(netTransfer, 'LayerNamesToIgnore', 'new_fc');

    lgraph = layerGraph(netTransfer);
    % 6.8 Create a layer graph for training with the output layer added
    lgraphTraining = addLayers(lgraph, classificationLayer('Name', 'new_classoutput'));
    lgraphTraining = connectLayers(lgraphTraining, 'new_softmax', 'new_classoutput');

    % 6.9 Visualize the network to ensure all layers are connected correctly
    analyzeNetwork(lgraphTraining);
else
    % 6.10 Load the layer graph from the existing network
    lgraphTraining = layerGraph(net);
end

% 7. Check for GPU Availability
if gpuDeviceCount > 0
    disp('GPU device found. Training will use GPU.');
else
    disp('No GPU device found. Training will use CPU.');
end

% 8. Set Training Options with GPU if Available
options = trainingOptions("adam", ...
    'MiniBatchSize', 64, ... % Reduced batch size to fit memory
    'MaxEpochs', 30, ...
    'InitialLearnRate', 1e-4, ...
    'ValidationFrequency', 5, ...
    'ValidationData', imdsValidation, ...
    'Verbose', false, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'auto'); % Automatically choose between GPU and CPU

% 9. Custom Training Loop to Save the Model Every 5 Epochs
numEpochs = options.MaxEpochs;
saveInterval = 5;

for epoch = 1:numEpochs
    % 9.1 Train for one epoch
    net_resFT = trainNetwork(imdsTrain, lgraphTraining, options);
    
    % 9.2 Save the model at specified intervals
    if mod(epoch, saveInterval) == 0
        save(fullfile(saveDir, sprintf('net_resFT_Epoch_%d.mat', epoch)), 'net_resFT');
        disp(['Model saved at epoch ' num2str(epoch)]);
    end
end

% 10. Save the Final Trained Network
save(fullfile(saveDir, 'net_resFT_Final.mat'), 'net_resFT');

% 11. Test the Trained Network
test_opt(net_resFT, imdsTest);

