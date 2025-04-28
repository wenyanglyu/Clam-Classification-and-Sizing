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

load("feretFeatures.mat");
% Load the feret features data
% Assuming feretFeatures is already loaded as a table with 962x9 dimensions

% Filter data to include only relevant labels (Cockle, Dosinia, Mussel, Tuatua)
selectedLabels = {'Cockle', 'Dosinia', 'Mussel', 'Tuatua'};
filteredData = feretFeatures(ismember(feretFeatures.Label, selectedLabels), :);

% Extract the features and labels
features = filteredData{:, 1:4}; % First 4 columns as features
labels = filteredData.Label;     % Last column as labels

% Feature names (assuming your table has column names)
featureNames = feretFeatures.Properties.VariableNames(1:4);

% Loop through each feature and create a violin plot
for i = 1:4
    % Create a new figure for each feature
    figure;
    
    % Prepare data for each species
    data = cell(1, length(selectedLabels));
    for j = 1:length(selectedLabels)
        data{j} = features(strcmp(labels, selectedLabels{j}), i);
    end
    
    % Plot the violin plot for the current feature with light blue color
    violin(data, 'xlabel', selectedLabels, 'facecolor', [0.68, 0.85, 0.90]);  % Light blue color
    
    % Set the y-axis label as the feature name
    ylabel(featureNames{i});
    
    % Set the same y-axis for all plots
    ylim([min(features(:, i)) max(features(:, i))]);

    % Rotate x-tick labels for better readability
    set(gca, 'XTickLabelRotation', 45);

    % Add the legend for median and mean without extra markers
    legend_handle = legend('Location', 'southwest');
    
    % Set the legend font size
    set(legend_handle, 'FontSize', 12);  % Set font size to 14
end
