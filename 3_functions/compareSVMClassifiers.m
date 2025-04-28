function compareSVMClassifiers(featureList)
    % Define SVM parameters
    svmConfigTypes = {'Linear', 'rbf_fixed', 'rbf_auto', 'Polynomial'};
    kernelFunctions = {'linear', 'rbf', 'rbf', 'polynomial'};
    boxConstraints = [1, 1, 1, 1];  % Default box constraints
    kernelScales = {'auto', 1, 'auto', 'auto'};  % Kernel scale settings
    
    % Initialize results table
    results = table('Size', [0 3], 'VariableTypes', {'string', 'string', 'double'}, ...
                    'VariableNames', {'Features', 'SVMConfigType', 'AverageAccuracy'});
    
    % Function to evaluate SVM classifier
    function [avgAcc, bestModel] = evaluateSVM(data, labels, kernelFunction, boxConstraint, kernelScale)
        cv = cvpartition(labels, 'KFold', 5);
        acc = zeros(cv.NumTestSets, 1);
        bestModel = [];
        bestAcc = 0;
        
        for i = 1:cv.NumTestSets
            trainIdx = training(cv, i);
            testIdx = test(cv, i);
            
            SVMModel = fitcecoc(data(trainIdx, :), labels(trainIdx), ...
                                'Learners', templateSVM('KernelFunction', kernelFunction, ...
                                                        'BoxConstraint', boxConstraint, ...
                                                        'KernelScale', kernelScale, ...
                                                        'Standardize', true));
            predictions = predict(SVMModel, data(testIdx, :));
            acc(i) = mean(predictions == labels(testIdx));
            
            if acc(i) > bestAcc
                bestAcc = acc(i);
                bestModel = SVMModel;
            end
        end
        
        avgAcc = mean(acc) * 100;  % Convert to percentage
    end
    
    % Initialize structure to save best models
    bestModels = struct();
    
    % Iterate over the list of features
    for fIdx = 1:numel(featureList)
        % Extract data and labels from the current feature set
        featureData = featureList{fIdx}{:, 1:end-1};
        featureLabels = categorical(featureList{fIdx}.Label);  % Convert to categorical
        featureName = inputname(1);  % Use input name for feature set identification
        
        % Iterate over SVM configurations
        bestFeatureModel = [];
        bestFeatureAcc = 0;
        
        for cIdx = 1:numel(svmConfigTypes)
            svmConfigType = svmConfigTypes{cIdx};
            kernelFunction = kernelFunctions{cIdx};
            boxConstraint = boxConstraints(cIdx);
            kernelScale = kernelScales{cIdx};
            
            % Evaluate SVM
            [avgAccuracy, bestModel] = evaluateSVM(featureData, featureLabels, kernelFunction, boxConstraint, kernelScale);
            
            % Add result to table
            newRow = {featureName, svmConfigType, avgAccuracy};
            results = [results; newRow];
            
            % Save the best model for this feature set
            if avgAccuracy > bestFeatureAcc
                bestFeatureAcc = avgAccuracy;
                bestFeatureModel = bestModel;
            end
        end
        
        % Save the best model for the current feature set
        modelName = sprintf('svmClassifier_%s', featureName);
        bestModels.(modelName) = bestFeatureModel;
    end
    
    % Display results
    disp(results);
end

