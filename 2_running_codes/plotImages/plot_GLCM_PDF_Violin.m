% 1. Path Management
SourceDir = 'D:/Clam_Classify_Sizing/';  % Modify as needed
saveDir = fullfile(SourceDir, '4_saved_files');  % Save folder for all files
tempDir = fullfile(SourceDir, '5_temp_files');  % Temporary files folder
demoDatasetDir = fullfile(SourceDir, '1_images', '3_demo_clams');
cropDir = fullfile(tempDir, 'crop');
resizeDir = fullfile(tempDir, 'resize');
funcDir = fullfile(SourceDir, '3_functions');  % Function folder
addpath(funcDir);
addpath(saveDir);

load("glcmFeatures.mat");
% Load the GLCM features data
% Assuming glcmFeatures is already loaded as a table with 962x9 dimensions

% Filter data to include only relevant labels (Cockle, Dosinia, Mussel, Tuatua)
selectedLabels = {'Cockle', 'Dosinia', 'Mussel', 'Tuatua'};
filteredData = glcmFeatures(ismember(glcmFeatures.Label, selectedLabels), :);

% Extract the features and labels
features = filteredData{:, 1:8}; % First 8 columns as features
labels = filteredData.Label;     % Last column as labels

% Feature names (assuming your table has column names)
featureNames = glcmFeatures.Properties.VariableNames(1:8);

% Loop through each feature and create a violin plot
for i = 1:8
    % Create a new figure for each feature
    figure;
    
    % Prepare data for each species
    data = cell(1, length(selectedLabels));
    for j = 1:length(selectedLabels)
        data{j} = features(strcmp(labels, selectedLabels{j}), i);
    end
    
    % Plot the violin plot for the current feature
    violin(data, 'xlabel', selectedLabels, ...
        'facecolor', [1 0.5 0; 0 0.5 1; 0.5 1 0; 0.5 0 1]);
    
    % Set the y-axis label as the feature name
    ylabel(featureNames{i});
    
    % Set the same y-axis for all plots
    ylim([min(features(:, i)) max(features(:, i))]);

    % Rotate x-tick labels for better readability
    set(gca, 'XTickLabelRotation', 45);
end
