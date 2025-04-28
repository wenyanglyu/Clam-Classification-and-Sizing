function results = predictWithClassifiers(saveDir)
    % Load demo features from saveDir
    load('demo_dctFeatures.mat', 'demo_dctFeatures');
    load('demo_feretFeatures.mat', 'demo_FeretFeatures');
    load('demo_feretResNetFeatures.mat', 'demo_feretResNetFeatures');
    load('demo_resNetFeatures.mat', 'demo_resNetFeatures');

    % Load classifiers from saveDir
    load('knnClassifiers.mat', 'knnClassifier_DCT', 'knnClassifier_Feret', 'knnClassifier_FeretResNet', 'knnClassifier_ResNet');
    load('rfClassifiers.mat', 'rfClassifier_DCT', 'rfClassifier_Feret', 'rfClassifier_FeretResNet', 'rfClassifier_ResNet');
    load('svmClassifiers.mat', 'svmClassifier_DCT', 'svmClassifier_Feret', 'svmClassifier_FeretResNet', 'svmClassifier_ResNet');

    % Define feature sets and corresponding classifiers
    featureSets = {demo_FeretFeatures, demo_dctFeatures, demo_resNetFeatures, demo_feretResNetFeatures};
    featureNames = {'Feret', 'DCT', 'ResNet', 'FeretResNet'};
    classifierTypes = {'SVM', 'KNN', 'RandomForest'};
    classifierStructs = {
        {svmClassifier_Feret, knnClassifier_Feret, rfClassifier_Feret}, ...
        {svmClassifier_DCT, knnClassifier_DCT, rfClassifier_DCT}, ...
        {svmClassifier_ResNet, knnClassifier_ResNet, rfClassifier_ResNet}, ...
        {svmClassifier_FeretResNet, knnClassifier_FeretResNet, rfClassifier_FeretResNet}
    };
    
    % Initialize results
    results = table('Size', [0 4], 'VariableTypes', {'string', 'string', 'string', 'cell'}, ...
                    'VariableNames', {'Features', 'Classifier', 'Label', 'Scores'});

    % Iterate over feature sets and classifiers
    for i = 1:numel(featureSets)
        features = featureSets{i};
        featureName = featureNames{i};
        
        % Ensure features are numeric and handle missing values
        features = table2array(features);
        features = fillmissing(features, 'constant', 0);

        for j = 1:numel(classifierTypes)
            classifierType = classifierTypes{j};
            classifier = classifierStructs{i}{j};
            
            % Predict labels and scores
            [predictedLabels, scores] = predict(classifier, features);
            
            % Append results
            for k = 1:numel(predictedLabels)
                newRow = {featureName, classifierType, char(predictedLabels(k)), num2cell(scores(k, :))};
                results = [results; newRow];
            end
        end
    end

    % Save results to a MAT file in saveDir
    save(fullfile(saveDir, 'predictionResults.mat'), 'results');
    disp(['Prediction results saved to ', fullfile(saveDir, 'predictionResults.mat')]);
end

