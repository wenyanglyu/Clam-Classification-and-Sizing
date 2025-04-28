% Load the DCT features data
load('dctFeatures.mat');

% Extract the first 9 DCT coefficients and labels
features = dctFeatures{:, 1:9}; % First 9 columns are DCT coefficients
labels = dctFeatures.Label;     % Last column contains the labels

% Get the unique clam species, excluding Pebble
uniqueClams = unique(labels);
uniqueClams(strcmp(uniqueClams, 'Pebble')) = []; % Remove Pebble from the list

% Initialize a matrix to store the normalized features for each species
normalizedFeatures = zeros(numel(uniqueClams), 9);

% Normalize and calculate the average features for each clam species
for i = 1:numel(uniqueClams)
    clamFeatures = features(strcmp(labels, uniqueClams{i}), :);
    
    % Normalize the features for the current clam species
    clamFeatures = (clamFeatures - min(clamFeatures(:))) ./ (max(clamFeatures(:)) - min(clamFeatures(:)));
    
    % Calculate the average normalized features
    normalizedFeatures(i, :) = mean(clamFeatures, 1);
end

% Reverse the order of the columns (DCT coefficients)
normalizedFeatures = normalizedFeatures(:, end:-1:1);

% Create the 3D bar graph
figure;
bar3(normalizedFeatures);

% Customize the plot

zlabel('Normalized Average DCT Value');

% Set custom labels for the x-axis and y-axis
xticks(1:9);
xticklabels(compose('DCTCoeff_%d', 9:-1:1)); % Reverse the tick labels

yticks(1:numel(uniqueClams));
yticklabels(uniqueClams);

