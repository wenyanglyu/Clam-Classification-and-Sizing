function saveRandomForestClassifier(featureList, featureNames, saveDir)
    % Define Random Forest parameters
    numTrees = 200;
    minLeafSize = 1;
    
    % Initialize structure to save models
    rfModels = struct();
    
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
        
        % Train Random Forest
        RFModel = trainRandomForest(data, labels, numTrees, minLeafSize);
        
        % Save the model for the current feature set
        modelName = sprintf('rfClassifier_%s', featureName);
        rfModels.(modelName) = RFModel;
        
        % Save the model to individual file (optional)
        %save(fullfile(saveDir, [modelName, '.mat']), 'RFModel');
    end
    
    % Save all models to a single MAT file
    save(fullfile(saveDir, 'rfClassifiers.mat'), '-struct', 'rfModels');
    
    disp('Random Forest classifiers trained and saved successfully.');
end

function RFModel = trainRandomForest(data, labels, numTrees, minLeafSize)
    % Train a Random Forest classifier
    RFModel = fitcensemble(data, labels, ...
                           'Method', 'Bag', ...
                           'NumLearningCycles', numTrees, ...
                           'Learners', templateTree('MinLeafSize', minLeafSize), ...
                           'ClassNames', unique(labels));
end

