function results = predictWithAlexNetNasNetSVM(saveDir)
    % Load AlexNet and NasNet features from saveDir
    load('demo_alexNetFeatures.mat', 'demo_alexNetFeatures');
    load('demo_nasNetFeatures.mat', 'demo_nasNetFeatures');

    % Load SVM classifiers from saveDir
    load('svmClassifiers.mat', 'svmClassifier_AlexNet', 'svmClassifier_NasNet');

    % Define feature sets and corresponding classifiers
    featureSets = {demo_alexNetFeatures, demo_nasNetFeatures};
    featureNames = {'AlexNet', 'NasNet'};
    classifierStructs = {svmClassifier_AlexNet, svmClassifier_NasNet};
    
    % Initialize results
    results = table('Size', [0 4], 'VariableTypes', {'string', 'string', 'string', 'cell'}, ...
                    'VariableNames', {'Features', 'Classifier', 'Label', 'Scores'});

    % Iterate over feature sets and classifiers
    for i = 1:numel(featureSets)
        features = featureSets{i};
        featureName = featureNames{i};
        classifier = classifierStructs{i};
        
        % Ensure features are numeric and handle missing values
        features = table2array(features);
        features = fillmissing(features, 'constant', 0);
        
        % Predict labels and scores using SVM
        [predictedLabels, scores] = predict(classifier, features);
        
        % Append results
        for k = 1:numel(predictedLabels)
            newRow = {featureName, 'SVM', char(predictedLabels(k)), num2cell(scores(k, :))};
            results = [results; newRow];
        end
    end

    % Save results to a MAT file in saveDir
    save(fullfile(saveDir, 'predictionResults_AlexNet_NasNet.mat'), 'results');
    disp(['Prediction results saved to ', fullfile(saveDir, 'predictionResults_AlexNet_NasNet.mat')]);
end

