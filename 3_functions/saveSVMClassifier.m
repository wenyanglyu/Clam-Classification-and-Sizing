function saveSVMClassifier(featureList, featureNames, saveDir)
    % Define SVM parameters for each feature set
    kernelFunction = 'polynomial';  % Use Polynomial kernel function for all feature sets
    boxConstraint = 1;  % Default box constraints
    kernelScale = 'auto';  % Kernel scale setting
    
    % Initialize structure to save models
    svmModels = struct();
    
    % Create save directory if it does not exist
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    
    % Iterate over feature sets
    for fIdx = 1:numel(featureList)
        % Extract data and labels from the current feature set
        data = featureList{fIdx}{:, 1:end-1};
        labels = categorical(featureList{fIdx}.Label);  % Convert to categorical
        featureName = featureNames{fIdx};
        
        % Train SVM
        SVMModel = trainSVM(data, labels, kernelFunction, boxConstraint, kernelScale);
        
        % Save the model for the current feature set
        modelName = sprintf('svmClassifier_%s', featureName);
        svmModels.(modelName) = SVMModel;
        
        % Predict and generate confusion matrix
        predictedLabels = predict(SVMModel, data);
        cm = confusionmat(labels, predictedLabels);
        confusionchart(cm, categories(labels));
        title(sprintf('Confusion Matrix: %s', featureName));
        
        % Save the confusion matrix as an image
        outputDir = fullfile(saveDir, 'classifier');
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        saveas(gcf, fullfile(outputDir, sprintf('confusionMatrix_%s.png', featureName)));
        close(gcf); % Close the figure after saving
        
        % Calculate and print the accuracy
        accuracy = sum(diag(cm)) / sum(cm(:));
        fprintf('Accuracy for %s: %.2f%%\n', featureName, accuracy * 100);
        
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

