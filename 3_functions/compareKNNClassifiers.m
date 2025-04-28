function compareKNNClassifiers(featureList)
    % Define k-NN parameters
    numNeighborsList = [1, 3, 5, 7];
    distanceMetrics = {'euclidean', 'cityblock', 'cosine', 'correlation'};
    
    % Initialize results table
    results = table('Size', [0 3], 'VariableTypes', {'string', 'string', 'double'}, ...
                    'VariableNames', {'Features', 'KNNConfigType', 'AverageAccuracy'});
    
    % Function to evaluate k-NN classifier
    function avgAcc = evaluateKNN(data, labels, numNeighbors, distanceMetric)
        cv = cvpartition(labels, 'KFold', 5);
        acc = zeros(cv.NumTestSets, 1);
        
        for i = 1:cv.NumTestSets
            trainIdx = training(cv, i);
            testIdx = test(cv, i);
            
            kNNModel = fitcknn(data(trainIdx, :), labels(trainIdx), ...
                               'NumNeighbors', numNeighbors, ...
                               'Distance', distanceMetric);
            predictions = predict(kNNModel, data(testIdx, :));
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
        
        % Iterate over k-NN configurations
        for k = numNeighborsList
            for d = distanceMetrics
                knnConfigType = sprintf('%dNN_%s', k, d{1});
                
                % Evaluate k-NN
                avgAccuracy = evaluateKNN(featureData, featureLabels, k, d{1});
                
                % Add result to table
                newRow = {featureName, knnConfigType, avgAccuracy};
                results = [results; newRow];
            end
        end
    end
    
    % Display results
    disp(results);
end

