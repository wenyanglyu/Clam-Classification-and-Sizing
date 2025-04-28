function saveSVMClassifiernoPebble(feretFeatures, dctFeatures, resNetFeatures, feretResNetFeatures, saveDir)
    % Prepare features and labels
    feretData = feretFeatures{:, 1:end-1};
    feretLabels = categorical(feretFeatures.Label);  % Convert to categorical
    
    dctData = dctFeatures{:, 1:end-1};
    dctLabels = categorical(dctFeatures.Label);  % Convert to categorical
    
    resNetData = resNetFeatures{:, 1:end-1};
    resNetLabels = categorical(resNetFeatures.Label);  % Convert to categorical
    
    feretResNetData = feretResNetFeatures{:, 1:end-1};
    feretResNetLabels = categorical(feretResNetFeatures.Label);  % Convert to categorical
    
    % Define SVM parameters for each feature set
    kernelFunction = 'polynomial';  % Use Polynomial kernel function for all feature sets
    boxConstraint = 1;  % Default box constraints
    kernelScale = 'auto';  % Kernel scale setting
    
    % List of feature sets and labels
    featureSets = {feretData, dctData, resNetData, feretResNetData};
    featureNames = {'Feret', 'DCT', 'ResNet', 'FeretResNet'};
    labelsList = {feretLabels, dctLabels, resNetLabels, feretResNetLabels};
    
    % Focus on specific labels for accuracy and confusion matrix calculation
    focusLabels = categorical({'Cockle', 'Dosinia', 'Mussel', 'Tuatua'});
    
    % Initialize structure to save models
    svmModels = struct();
    
    % Create save directory if it does not exist
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    
    % Iterate over feature sets
    for fIdx = 1:numel(featureSets)
        data = featureSets{fIdx};
        labels = labelsList{fIdx};
        featureName = featureNames{fIdx};
        
        % Filter labels and data for focusLabels only
        isFocusLabel = ismember(labels, focusLabels);
        filteredData = data(isFocusLabel, :);
        filteredLabels = labels(isFocusLabel);
        
        % Train SVM
        SVMModel = trainSVM(filteredData, filteredLabels, kernelFunction, boxConstraint, kernelScale);
        
        % Predict and filter the predicted labels to only focus on the four clams
        predictedLabels = predict(SVMModel, filteredData);
        isFocusPred = ismember(predictedLabels, focusLabels);
        filteredPredictedLabels = predictedLabels(isFocusPred);
        filteredTrueLabels = filteredLabels(isFocusPred);
        
        % Generate the confusion matrix and chart only for the four clams
        cm = confusionmat(filteredTrueLabels, filteredPredictedLabels, 'Order', focusLabels);
        confusionchart(cm, focusLabels);
        title(sprintf('Confusion Matrix: %s', featureName));
        
        % Save the confusion matrix as an image
        outputDir = '/home/sxb7657/Downloads/Clam/multipleClassifier/classifier';
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        saveas(gcf, fullfile(outputDir, sprintf('confusionMatrix_%s.png', featureName)));
        close(gcf); % Close the figure after saving
        
        % Calculate and print the accuracy for the four clams
        accuracy = sum(diag(cm)) / sum(cm(:));
        fprintf('Accuracy for %s (focused on specific labels): %.2f%%\n', featureName, accuracy * 100);
        
        % Optional: save the individual model
        %save(fullfile(saveDir, [modelName, '.mat']), 'SVMModel');
    end
    
    % Save all models to a single MAT file
    save(fullfile(saveDir, 'svmClassifiers.mat'), '-struct', 'svmModels');
    
    disp('SVM classifiers trained and saved successfully.');
end

function SVMModel = trainSVM(data, labels, kernelFunction, boxConstraint, kernelScale)
    % Train an SVM classifier
    SVMModel = fitcecoc(data, labels, ...
                        'Learners', templateSVM('KernelFunction', kernelFunction, ...
                                                'BoxConstraint', boxConstraint, ...
                                                'KernelScale', kernelScale, ...
                                                'Standardize', true));
end

