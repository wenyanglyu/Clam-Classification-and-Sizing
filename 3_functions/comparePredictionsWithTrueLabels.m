function accuracyResults = comparePredictionsWithTrueLabels(demo_predict, trueLabels, validLabels)
    % Initialize results table
    accuracyResults = table('Size', [0 3], 'VariableTypes', {'string', 'string', 'double'}, ...
                            'VariableNames', {'Features', 'Classifier', 'Accuracy'});
    
    % Get the unique feature and classifier types
    featureTypes = unique(demo_predict.Features);
    classifierTypes = unique(demo_predict.Classifier);
    
    % Iterate over each feature type and classifier type
    for i = 1:numel(featureTypes)
        for j = 1:numel(classifierTypes)
            % Filter the demo_predict table for the current feature and classifier
            filterIdx = strcmp(demo_predict.Features, featureTypes{i}) & ...
                        strcmp(demo_predict.Classifier, classifierTypes{j});
            filteredPredictions = demo_predict(filterIdx, :);
            
            % Initialize counters
            totalCount = 0;
            correctCount = 0;
            
            % Compare each prediction with the true label
            for k = 1:numel(trueLabels)
                predictedLabel = filteredPredictions.Label{k};
                trueLabel = trueLabels{k};
                
                % Check if the true label is valid
                if ismember(trueLabel, validLabels)
                    totalCount = totalCount + 1;
                    if strcmp(predictedLabel, trueLabel)
                        correctCount = correctCount + 1;
                    end
                end
            end
            
            % Calculate accuracy
            if totalCount > 0
                accuracy = (correctCount / totalCount) * 100;
            else
                accuracy = NaN;
            end
            
            % Append results
            newRow = {featureTypes{i}, classifierTypes{j}, accuracy};
            accuracyResults = [accuracyResults; newRow];
        end
    end
    
    % Display results
    disp(accuracyResults);
    
    % Save results to a MAT file
    save('accuracyResults.mat', 'accuracyResults');
end