% 1. Path Management
SourceDir = 'D:/Clam_Classify_Sizing/';  % Modify as needed
saveDir = fullfile(SourceDir, '4_saved_files');  % Save folder for all files
tempDir = fullfile(SourceDir, '5_temp_files');  % Temporary files folder
classifDemoDir = fullfile(SourceDir, '1_images', '3_classifDemo_clams');
cropDir = fullfile(tempDir, 'crop');
resizeDir = fullfile(tempDir, 'resize');
funcDir = fullfile(SourceDir, '3_functions');  % Function folder
addpath(funcDir);
addpath(saveDir);

% 2. Load Trained Classifiers
load('svmClassifiers.mat');

% 3. Load and Process Demo Dataset
shellNumber = 4;
cropCoordinate = autoCropImages(shellNumber, classifDemoDir, cropDir);
pad_and_resize_images(cropDir, resizeDir);

% 4. Save Demo Features
imds_demo = imageDatastore(resizeDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames', 'FileExtensions', {'.JPG'});

% Measure the execution time for saveAlexNetFeatures
tic;  % Start timer
saveAlexNetFeatures(imds_demo, saveDir);
timeAlexNet = toc;  % Stop timer and get elapsed time
fprintf('Time taken by saveAlexNetFeatures: %.2f seconds\n', timeAlexNet);

% Measure the execution time for saveNasNetFeatures
tic;  % Start timer
saveNasNetFeatures(imds_demo, saveDir);
timeNasNet = toc;  % Stop timer and get elapsed time
fprintf('Time taken by saveNasNetFeatures: %.2f seconds\n', timeNasNet);

% Measure the execution time for saveResNetFeatures
tic;  % Start timer
saveResNetFeatures(imds_demo, saveDir);
timeResNet = toc;  % Stop timer and get elapsed time
fprintf('Time taken by saveResNetFeatures: %.2f seconds\n', timeResNet);

% 5. Load Saved Demo Features
load('alexNetFeatures.mat', 'alexNetFeatures');
load('nasNetFeatures.mat', 'nasNetFeatures');
load('resNetFeatures.mat', 'resNetFeatures');

% 6. Extract feature data (excluding the label column)
alexNetFeaturesData = alexNetFeatures{:, 1:end-1};  % All columns except the last one (assumed to be labels)
nasNetFeaturesData = nasNetFeatures{:, 1:end-1};    % All columns except the last one
resNetFeaturesData = resNetFeatures{:, 1:end-1};    % All columns except the last one

% Handle missing values by filling them with zeroes or another appropriate value
alexNetFeaturesData = fillmissing(alexNetFeaturesData, 'constant', 0);
nasNetFeaturesData = fillmissing(nasNetFeaturesData, 'constant', 0);
resNetFeaturesData = fillmissing(resNetFeaturesData, 'constant', 0);

% 7. Define the true labels based on the subfolder names
trueLabels = imds_demo.Labels;  % Automatically extracted from the subfolder names

% 8. Define the valid labels for classification comparison
trueCategories = categories(trueLabels);  % Extract unique valid labels from trueLabels

% 9. Predict Results Using AlexNet, NasNet, and ResNet Features with the Trained SVM Classifiers
[YPred_AlexNet, scores_AlexNet] = predict(svmClassifier_AlexNet, alexNetFeaturesData);
[YPred_NasNet, scores_NasNet] = predict(svmClassifier_NASNet, nasNetFeaturesData);
[YPred_ResNet, scores_ResNet] = predict(svmClassifier_ResNet, resNetFeaturesData);

% Align the predicted labels with the true labels
YPred_AlexNet = categorical(YPred_AlexNet, trueCategories);  % Ensure predictions include all true categories
YPred_NasNet = categorical(YPred_NasNet, trueCategories);    % Ensure predictions include all true categories
YPred_ResNet = categorical(YPred_ResNet, trueCategories);    % Ensure predictions include all true categories

% 10. Compare the Predictions with the True Labels for AlexNet, NasNet, and ResNet Features
accuracy_AlexNet = sum(YPred_AlexNet == trueLabels) / numel(trueLabels);
accuracy_NasNet = sum(YPred_NasNet == trueLabels) / numel(trueLabels);
accuracy_ResNet = sum(YPred_ResNet == trueLabels) / numel(trueLabels);

% 11. Display Accuracy Results
disp('Accuracy Results for AlexNet Features:');
disp(accuracy_AlexNet * 100);  % Display accuracy as a percentage

disp('Accuracy Results for NasNet Features:');
disp(accuracy_NasNet * 100);  % Display accuracy as a percentage

disp('Accuracy Results for ResNet Features:');
disp(accuracy_ResNet * 100);  % Display accuracy as a percentage

% 12. Generate and display the confusion matrices
confMat_AlexNet = confusionmat(trueLabels, YPred_AlexNet);
confMat_NasNet = confusionmat(trueLabels, YPred_NasNet);
confMat_ResNet = confusionmat(trueLabels, YPred_ResNet);

% Plot the confusion matrices
figure;
confusionchart(confMat_AlexNet, trueCategories);
title('Confusion Matrix for AlexNet Features');

figure;
confusionchart(confMat_NasNet, trueCategories);
title('Confusion Matrix for NasNet Features');

figure;
confusionchart(confMat_ResNet, trueCategories);
title('Confusion Matrix for ResNet Features');
