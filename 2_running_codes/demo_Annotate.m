% 1. Path Management
SourceDir = 'D:/Clam_Classify_Sizing/';  % Modify as needed
saveDir = fullfile(SourceDir, '4_saved_files');  % Save folder for all files
tempDir = fullfile(SourceDir, '5_temp_files');  % Temporary files folder
demoAnnotateDir = fullfile(SourceDir, '1_images', '5_demoAnnotate');
cropDir = fullfile(tempDir, 'crop');
resizeDir = fullfile(tempDir, 'resize');
funcDir = fullfile(SourceDir, '3_functions');  % Function folder
addpath(funcDir);
addpath(saveDir);

% 2. Load Trained Classifiers
load('svmClassifiers.mat');

% 3. Load and Process Demo Dataset
shellNumber = 6;
cropCoordinate = autoCropImages(shellNumber, classifDemoDir, cropDir);
pad_and_resize_images(cropDir, resizeDir);

% 4. Save Demo Features
imds_demo = imageDatastore(resizeDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames', 'FileExtensions', {'.JPG'});

% Measure the execution time for saveResNetFeatures
tic;  % Start timer
saveResNetFeatures(imds_demo, saveDir);
timeResNet = toc;  % Stop timer and get elapsed time
fprintf('Time taken by saveResNetFeatures: %.2f seconds\n', timeResNet);

% 5. Load Saved Demo Features
load('resNetFeatures.mat', 'resNetFeatures');

% 6. Extract feature data (excluding the label column)
resNetFeaturesData = resNetFeatures{:, 1:end-1};    % All columns except the last one

% Handle missing values by filling them with zeroes or another appropriate value
resNetFeaturesData = fillmissing(resNetFeaturesData, 'constant', 0);

% 7. Predict Results Using AlexNet, NasNet, and ResNet Features with the Trained SVM Classifiers
[YPred_ResNet, scores_ResNet] = predict(svmClassifier_ResNet, resNetFeaturesData);


