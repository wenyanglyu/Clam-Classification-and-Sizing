function saveKNNClassifier(featureList, featureNames, saveDir)
    % Define KNN parameters
    numNeighbors = 3;
    distanceMetric = 'cityblock';
    
    % Initialize structure to save models
    knnModels = struct();
    
    % Create save directory if it does not exist
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    
    % Iterate over the feature list
    for fIdx = 1:numel(featureList)
        % Extract data and labels from the current feature set
        data = featureList{fIdx}{:, 1:end-1};
        labels = categorical(featureList{fIdx}.Label);  % Convert to categorical
        featureName = featureNames{fIdx};
        
        % Train KNN
        KNNModel = trainKNN(data, labels, numNeighbors, distanceMetric);
        
        % Save the model for the current feature set
        modelName = sprintf('knnClassifier_%s', featureName);
        knnModels.(modelName) = KNNModel;
        
        % Save the model to individual file (optional)
        %save(fullfile(saveDir, [modelName, '.mat']), 'KNNModel');
    end
    
    % Save all models to a single MAT file
    save(fullfile(saveDir, 'knnClassifiers.mat'), '-struct', 'knnModels');
    
    disp('k-NN classifiers trained and saved successfully.');
end

function KNNModel = trainKNN(data, labels, numNeighbors, distanceMetric)
    % Train a k-NN classifier
    KNNModel = fitcknn(data, labels, ...
                       'NumNeighbors', numNeighbors, ...
                       'Distance', distanceMetric, ...
                       'Standardize', true);
end

