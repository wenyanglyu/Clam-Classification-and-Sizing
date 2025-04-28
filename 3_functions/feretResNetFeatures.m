function feretResNetFeatures(feretFeatures, resNetFeatures, savePath)
    
    % Extract features and labels from both feature sets
    feretData = feretFeatures{:, 1:end-1};  % Exclude the label column
    resNetData = resNetFeatures{:, 1:end-1};  % Exclude the label column
    
    % Ensure the labels are the same in both feature sets
    assert(isequal(feretFeatures.Label, resNetFeatures.Label), 'Labels do not match');
    
    % Combine the features
    combinedFeatures = [feretData, resNetData];
    labels = feretFeatures.Label;  % Labels are the same in both feature sets
    
    % Create a new table with combined features and labels
    combinedFeatureNames = [feretFeatures.Properties.VariableNames(1:end-1), ...
                            resNetFeatures.Properties.VariableNames(1:end-1)];
    feretResNetFeatures = array2table(combinedFeatures, 'VariableNames', combinedFeatureNames);
    feretResNetFeatures.Label = labels;
    
    % Save the combined features to a MAT file
    save(fullfile(savePath, 'feretResNetFeatures.mat'), 'feretResNetFeatures');
    disp(['Combined features data saved to ', fullfile(savePath, 'feretResNetFeatures.mat')]);
end
