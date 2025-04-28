function compareRandomForestClassifiers(featureList)
    % Define Random Forest parameters
    numTreesList = [50, 100, 200];
    minLeafSizes = [1, 5, 10];
    
    % Initialize results table
    results = table('Size', [0 3], 'VariableTypes', {'string', 'string', 'double'}, ...
                    'VariableNames', {'Features', 'RandomForestConfigType', 'AverageAccuracy'});
    
    % Function to evaluate Random Forest classifier
    function avgAcc = evaluateRandomForest(data, labels, numTrees, minLeafSize)
        cv = cvpartition(labels, 'KFold', 5);
        acc = zeros(cv.NumTestSets, 1);
        
        for i = 1:cv.NumTestSets
            trainIdx = training(cv, i);
            testIdx = test(cv, i);
            
            treeTemplate = templateTree('MinLeafSize', minLeafSize);
            RFModel = fitcensemble(data(trainIdx, :), labels(trainIdx), ...
                                   'Method', 'Bag', ...
                                   'NumLearningCycles', numTrees, ...
                                   'Learners', treeTemplate);
            predictions = predict(RFModel, data(testIdx, :));
            acc(i) = mean(predictions == labels(testIdx));
        end
        
        avgAcc = mean(acc) * 100;  % Convert to percentage
    end
    
    % Iterate over the list of features
    for fIdx = 1:numel(featureList)
        % Extract data and labels from the current feature set
        featureData = featureList{fIdx}{:, 1:end-1};
        featureLabels = categorical(featureList{fIdx}.Label);  % Convert to categorical
        featureName = inputname(1);  % Use input name for feature set identification
        
        % Iterate over Random Forest configurations
        for numTrees = numTreesList
            for minLeafSize = minLeafSizes
                rfConfigType = sprintf('%dTrees_%dLeafSize', numTrees, minLeafSize);
                
                % Evaluate Random Forest
                avgAccuracy = evaluateRandomForest(featureData, featureLabels, numTrees, minLeafSize);
                
                % Add result to table
                newRow = {featureName, rfConfigType, avgAccuracy};
                results = [results; newRow];
            end
        end
    end
    
    % Display results
    disp(results);
end

