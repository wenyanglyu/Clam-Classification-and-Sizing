% 1. Path Management
SourceDir = 'D:/Clam_Classify_Sizing/';  % Modify as needed
datasetDir = fullfile(SourceDir, '1_images', '4_dataset'); 
saveDir = fullfile(SourceDir, '4_saved_files');
addpath(genpath(fullfile(SourceDir, '3_functions')));  % Add functions to path
addpath(saveDir);  % Add the save directory to path

% 2. Load Training Dataset
imds_training = imageDatastore(datasetDir, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

% 3. Save Features Before Training the Classifier
saveFeret(imds_training, saveDir);
saveGLCMFeatures(imds_training, saveDir);
saveDCTFeatures(imds_training, saveDir);
saveResNetFeatures(imds_training, saveDir);
saveFeretResNetFeatures(feretFeatures, resNetFeatures, saveDir);
saveNasNetFeatures(imds_training, saveDir);
saveAlexNetFeatures(imds_training, saveDir);

% 4.1 Find Out Best Parameters Set for Different Features

% Load features before comparison (if not already in memory)
load('feretFeatures.mat');
load('dctFeatures.mat');
load('resNetFeatures.mat');
load('feretResNetFeatures.mat');
load('glcmFeatures.mat');
load('nasNetFeatures.mat');
load('alexNetFeatures.mat');

% Define feature list and names
featureList = {feretFeatures, dctFeatures, resNetFeatures, feretResNetFeatures, glcmFeatures, nasNetFeatures, alexNetFeatures};
featureNames = {'Feret', 'DCT', 'ResNet', 'FeretResNet', 'GLCM', 'NASNet', 'AlexNet'};

% Compare classifiers to determine best parameters
compareSVMClassifiers(featureList, featureNames);
compareKNNClassifiers(featureList, featureNames);
compareRandomForestClassifiers(featureList, featureNames);

% 4.2 Train classifiers
saveSVMClassifier(featureList, featureNames, saveDir);
saveKNNClassifier(featureList, featureNames, saveDir);
saveRandomForestClassifier(featureList, featureNames, saveDir);

% 5. Optionally load classifiers if needed later
load('svmClassifiers.mat');  % Load the SVM models if needed later
load('knnClassifiers.mat');  % Load the k-NN models if needed later
load('rfClassifiers.mat');  % Load the Random Forest models if needed later

