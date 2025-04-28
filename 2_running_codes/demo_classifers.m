% 1. Path Management
SourceDir = 'D:/Clam_Classify_Sizing/';  % Modify as needed
saveDir = fullfile(SourceDir, '4_saved_files');  % Directory to save all files
tempDir = fullfile(SourceDir, '5_temp_files');  % Temporary files folder
classifDemoDir = fullfile(SourceDir, '1_images', '3_classifDemo_clams');  % Demo dataset directory
cropDir = fullfile(tempDir, 'crop');  % Directory for cropped images
resizeDir = fullfile(tempDir, 'resize');  % Directory for resized images
funcDir = fullfile(SourceDir, '3_functions');  % Function directory

% Add necessary directories to the MATLAB path
addpath(funcDir);
addpath(saveDir);

% 2. Load Trained Classifiers
load('svmClassifiers.mat');
load('knnClassifiers.mat');
load('rfClassifiers.mat');

% 3. Load and Process Demo Dataset
shellNumber = 4;  % Number of shells to crop per image
cropCoordinate = autoCropImages(shellNumber, classifDemoDir, cropDir);  % Auto-crop images
pad_and_resize_images(cropDir, resizeDir);  % Pad and resize images

% Create an image datastore for the demo dataset
imds_demo = imageDatastore(resizeDir, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames', ...
    'FileExtensions', {'.JPG'});

% 4. Save Demo Features
saveFeret(imds_demo, saveDir);
saveGLCMFeatures(imds_demo, saveDir);
saveDCTFeatures(imds_demo, saveDir);
saveResNetFeatures(imds_demo, saveDir);
saveFeretResNetFeatures(imds_demo, saveDir);

% 5. Load Saved Demo Features
load('feretFeatures.mat', 'feretFeatures');
load('dctFeatures.mat', 'dctFeatures');
load('resNetFeatures.mat', 'resNetFeatures');
load('feretResNetFeatures.mat', 'feretResNetFeatures');

% 6. Define True Labels Based on Subfolder Names
trueLabels = imds_demo.Labels;  % Automatically extracted from the subfolder names

% 7. Define the Valid Labels for Classification Comparison
validLabels = categories(trueLabels);  % Automatically get the unique valid labels from trueLabels

% 8. Predict Results for All Features Using All Classifiers
demo_Predicted_Results = predictWithClassifiers(saveDir);

% 9. Compare the Predicted Labels Against the True Labels and Calculate Accuracy
accuracyResults = comparePredictionsWithTrueLabels(demo_Predicted_Results, trueLabels, validLabels);

% 10. Calculate and Annotate Diameters
% Load camera parameters
load('cameraParams.mat', 'cameraParams');

% Calculate Feret Coordinates and save results
feretResults = feretCoordinate(cropDir, classifDemoDir);

% Combine coordinates, labels, and Feret results
cropLabelFeret = combineCropLabelsFeret(cropCoordinate, trueLabels, feretResults);

% Calculate diameters based on Feret results and camera parameters
diameters = calculateRealWorldDiameters(cameraParams, cropLabelFeret);

% Combine all data including diameters
cropLabelFeretDiameter = combineAllData(cropLabelFeret, diameters);

% Display and save final results
disp('Final Combined Results:');
disp(cropLabelFeretDiameter);
save(fullfile(saveDir, 'cropLabelFeretDiameter.mat'), 'cropLabelFeretDiameter');

% Annotate the original images with labels and diameters
annotate_images(classifDemoDir, cropLabelFeretDiameter);
