% Load the data from the mat file
load feretFeatures.mat;

% Define the set of labels to consider
labelsToConsider = {'Cockle', 'Dosinia', 'Mussel', 'Tuatua'};

% Define the features to plot
featuresToPlot = {'MinMaxRatio', 'MaxFeretDiameter', 'MinFeretDiameter', 'Area'};
featureTitles = {'MinMaxRatio', 'Max Feret Diameter', 'Min Feret Diameter', 'Area'};
fileNames = {'MinMaxRatio.png', 'MaxFeretDiameter.png', 'MinFeretDiameter.png', 'Area.png'};

% Define colors for each label
colors = lines(length(labelsToConsider));

% Define the output directory
outputDir = '/home/sxb7657/Downloads/Clam/multipleClassifier/features';

% Loop through each feature
for fIdx = 1:length(featuresToPlot)
    % Initialize a figure for the plot
    figure;
    hold on;
    
    % Loop through each label in the set
    for i = 1:length(labelsToConsider)
        % Get the current label
        currentLabel = labelsToConsider{i};
        
        % Extract rows where the Label matches the current label
        labelRows = strcmp(feretFeatures.Label, currentLabel);
        
        % Extract the corresponding feature values
        featureValues = feretFeatures.(featuresToPlot{fIdx})(labelRows);
        
        % Print the number of shells for this label
        numShells = sum(labelRows);
        fprintf('%s: %d shells\n', currentLabel, numShells);
        
        % Calculate the percentage distribution
        [f, xi] = ksdensity(featureValues, 'Function', 'pdf');
        
        % Convert the density to percentage
        f = f / sum(f) * 100;
        
        % Plot the smoothed percentage distribution
        plot(xi, f, 'LineWidth', 2, 'Color', colors(i,:), 'DisplayName', [currentLabel, ' (n=', num2str(numShells), ')']);
    end
    
    % Add labels and title
    xlabel(featuresToPlot{fIdx});
    ylabel('Percentage');
    title(['Percentage Distribution of ', featureTitles{fIdx}, ' for Each Label']);
    legend('show');
    
    % Save the figure as a PNG file in the specified directory
    saveas(gcf, fullfile(outputDir, fileNames{fIdx}));
    
    % Close the figure to avoid overlapping issues
    close(gcf);
end

