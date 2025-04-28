% 1. Path Management
SourceDir = 'D:/Clam_Classify_Sizing/';  % Modify as needed
saveDir = fullfile(SourceDir, '4_saved_files');  % Save folder for all files
tempDir = fullfile(SourceDir, '5_temp_files');  % Temporary files folder
classifDemoDir = fullfile(SourceDir, '1_images', '3_classifDemo_clams');
cropDir = fullfile(tempDir, 'crop');
resizeDir = fullfile(tempDir, 'resize');
annotatedDir = fullfile(classifDemoDir, 'annotated');
funcDir = fullfile(SourceDir, '3_functions');  % Function folder
camDir = fullfile(SourceDir, 'calibration', 'clothesHorse');
addpath(funcDir);
addpath(saveDir);

% 2. Load Camera Parameters and Model
cameraParamsFile = fullfile(saveDir, 'cameraParams.mat');
modelFile = fullfile(saveDir, 'net_Drop_withoutEnhance.mat');  % Modify as needed for different models

load(cameraParamsFile);
load(modelFile);

% 3. Process Demo Dataset
cropCoordinate = autoCropImages(classifDemoDir, cropDir);
pad_and_resize_images(cropDir, resizeDir);

% Ensure cropCoordinate is a cell array
if ~iscell(cropCoordinate)
    error('cropCoordinate should be a cell array.');
end

% Create an imageDatastore from the resize directory
imdsDemo = imageDatastore(resizeDir, 'FileExtensions', {'.JPG'}, 'IncludeSubfolders', false);

% 4. Load the Neural Network Model
try
    net_Drop = loadedData.net_resFT;  % Adjust according to your model variable name
    disp('Network assigned from loadedData.');
catch
    try
        net_Drop = net_resFT;
        disp('Network assigned from net_resFT.');
    catch
        error('Neither loadedData.net_resFT nor net_resFT is available.');
    end
end

% 5. Classify Images and Post-process Results
[YPred, scores] = classify(net_Drop, imdsDemo);

% Post-process YPred based on scores
finalLabels = cell(size(YPred));
threshold = 0.1;

for i = 1:length(YPred)
    if max(scores(i, :)) > threshold
        finalLabels{i} = char(YPred(i));
    else
        finalLabels{i} = 'others';
    end
end

% 6. Label Coordination and Feret Calculation
numImages = numel(cropCoordinate);
coorLabels = cell(numImages, 1);
labelIndex = 1;

for i = 1:numImages
    numCoords = size(cropCoordinate{i}, 1);
    endIndex = min(labelIndex + numCoords - 1, length(finalLabels));
    labelsForCoords = finalLabels(labelIndex:endIndex);

    if numCoords ~= numel(labelsForCoords)
        warning('Number of coordinates (%d) does not match number of labels (%d) for image %d.', numCoords, numel(labelsForCoords), i);
        minSize = min(numCoords, numel(labelsForCoords));
        cropCoordinate{i} = cropCoordinate{i}(1:minSize, :);
        labelsForCoords = labelsForCoords(1:minSize);
    end

    coorLabels{i} = [num2cell(cropCoordinate{i}), labelsForCoords];
    labelIndex = endIndex + 1;
end

% Display the coordinates and labels
disp('Coordinates and Labels:');
for i = 1:numel(coorLabels)
    fprintf('Image %d:\n', i);
    disp(coorLabels{i});
end

% Calculate Feret Coordinates and save results
feretResults = feretCoordinate(cropDir, annotatedDir);

% Combine coorLabels and feretResults into cropLabelFeret
cropLabelFeret = cell(numImages, 1);
feretIndex = 1;

for i = 1:numImages
    numCoords = size(coorLabels{i}, 1);
    tempResults = cell(numCoords, 7);
    for j = 1:numCoords
        tempResults(j, 1:3) = coorLabels{i}(j, :);
        if feretIndex <= size(feretResults, 1)
            tempResults(j, 4:7) = num2cell(feretResults(feretIndex, :));
            feretIndex = feretIndex + 1;
        else
            tempResults(j, 4:7) = {NaN, NaN, NaN, NaN};
        end
    end
    cropLabelFeret{i} = tempResults;
end

% Display the combined results
disp('Combined Coordinates, Labels, and Feret Coordinates:');
for i = 1:numel(cropLabelFeret)
    fprintf('Image %d:\n', i);
    disp(cropLabelFeret{i});
end

% Calculate real-world diameters using camera parameters
diameters = calculateRealWorldDiameters(cameraParams, cropLabelFeret);

% Combine cropLabelFeret and diameters into cropLabelFeretDiameter
cropLabelFeretDiameter = cell(numImages, 1);
diameterIndex = 1;

for i = 1:numImages
    tempResults = cropLabelFeret{i};
    for j = 1:size(tempResults, 1)
        if diameterIndex <= length(diameters)
            tempResults(j, 8) = num2cell(diameters(diameterIndex));
            diameterIndex = diameterIndex + 1;
        else
            tempResults(j, 8) = {NaN};
        end
    end
    cropLabelFeretDiameter{i} = tempResults;
end

% Display the final combined results
disp('Combined Coordinates, Labels, Feret Coordinates, and Diameters:');
for i = 1:numel(cropLabelFeretDiameter)
    fprintf('Image %d:\n', i);
    disp(cropLabelFeretDiameter{i});
end

% Save the final combined results
save(fullfile(saveDir, 'cropLabelFeretDiameter.mat'), 'cropLabelFeretDiameter');

% Annotate the original images
annotate_images(classifDemoDir, cropLabelFeretDiameter);

% 7. Evaluate Model Accuracy

trueLabels = {
    'Mussel'; 'Mussel'; 'Mussel'; 'Mussel'; 'Mussel'; 
    'Mussel'; 'Mussel'; 'Mussel'; 'Mussel'; 'Mussel'; 
    'Mussel'; 'Mussel'; 'Mussel'; 'Mussel'; 'Mussel'; 
    'Mussel'; 'Mussel'; 'Mussel'; 'Mussel'; 'Mussel'; 
    'Dosinia'; 'Dosinia'; 'Dosinia'; 'Dosinia'; 'Dosinia'; 
    'Dosinia'; 'Dosinia'; 'Dosinia'; 'Dosinia'; 'Dosinia'; 
    'Dosinia'; 'Dosinia'; 'Dosinia'; 'Dosinia'; 'Dosinia'; 
    'Dosinia'; 'Dosinia'; 'Dosinia'; 'Dosinia'; 'Dosinia'; 
    'Tuatua'; 'Tuatua'; 'Tuatua'; 'Tuatua'; 'Tuatua'; 
    'Tuatua'; 'Tuatua'; 'Tuatua'; 'Tuatua'; 'Tuatua'; 
    'Tuatua'; 'Tuatua'; 'Tuatua'; 'Tuatua'; 'Tuatua'; 
    'Tuatua'; 'Tuatua'; 'Tuatua'; 'Tuatua'; 'Tuatua'; 
    'Cockle'; 'Cockle'; 'Cockle'; 'Cockle'; 'Cockle'; 
    'Cockle'; 'Cockle'; 'Cockle'; 'Cockle'; 'Cockle'; 
    'Cockle'; 'Cockle'; 'Cockle'; 'Cockle'; 'Cockle'; 
    'Cockle'; 'Cockle'; 'Cockle'; 'Cockle'; 'Cockle'; 
    'Pebble'; 'Pebble'; 'Pebble'; 'Pebble'; 'Pebble'; 
    'Pebble'; 'Pebble'; 'Pebble'; 'Pebble'; 'Pebble'; 
    'Pebble'; 'Pebble'; 'Pebble'; 'Pebble'; 'Pebble'; 
    'Pebble'; 'Pebble'; 'Pebble'; 'Pebble'; 'Pebble'
};

save(fullfile(saveDir, 'labels.mat'), 'trueLabels');

% Correct the label 'Mussle' to 'Mussel' in YPred
try
    YPred = renamecats(YPred, 'Mussle', 'Mussel');
catch
    disp('Category ''Mussle'' not found in YPred. No renaming needed.');
end

% Convert trueLabels to categorical array
trueLabelsCategorical = categorical(trueLabels);

% Calculate the accuracy
accuracy = sum(trueLabelsCategorical == YPred) / numel(trueLabelsCategorical);
fprintf('Accuracy: %.2f%%\n', accuracy * 100);

% Generate and display the confusion matrix
confMat = confusionmat(trueLabelsCategorical, YPred);

% Plot the confusion matrix
figure;
confusionchart(trueLabelsCategorical, YPred);
title('Confusion Matrix');

