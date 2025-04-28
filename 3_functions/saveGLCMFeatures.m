function saveGLCMFeatures(imds, savePath)
    disp('The process is ongoing, please be patient...');
    offsets = [0 1; -1 1; -1 0; -1 -1];
    numImages = numel(imds.Files);
    
    % Initialize arrays to store features for each label
    featureSums = containers.Map({'Cockle', 'Dosinia', 'Mussel', 'Tuatua'}, ...
                                 {zeros(1, 8), zeros(1, 8), zeros(1, 8), zeros(1, 8)});
    labelCounts = containers.Map({'Cockle', 'Dosinia', 'Mussel', 'Tuatua'}, ...
                                 {0, 0, 0, 0});
    
    labels = cell(numImages, 1);  % Initialize as cell array
    
    for i = 1:numImages
        img = readimage(imds, i);
        label = imds.Labels(i); % Get the label for the current image
        clamType = char(label); % Convert to char for saving in table
        labels{i} = clamType;
        
        % Skip if the clamType is not one of the expected labels
        if ~isKey(featureSums, clamType)
            continue;
        end
        
        grayImage = rgb2gray(img);

        % Compute GLCMs for the specified offsets
        glcm = graycomatrix(grayImage, 'Offset', offsets);
        stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
        
        % Feature fusion: calculate mean and standard deviation across all directions
        featureVector = [mean(stats.Contrast), std(stats.Contrast), ...
                         mean(stats.Correlation), std(stats.Correlation), ...
                         mean(stats.Energy), std(stats.Energy), ...
                         mean(stats.Homogeneity), std(stats.Homogeneity)];
                     
        % Accumulate feature vectors for the corresponding label
        featureSums(clamType) = featureSums(clamType) + featureVector;
        labelCounts(clamType) = labelCounts(clamType) + 1;
    end
    
    % Calculate the average feature vector for each label
    featureMeans = containers.Map('KeyType', 'char', 'ValueType', 'any');
    for key = keys(featureSums)
        clamType = char(key);
        if labelCounts(clamType) > 0
            featureMeans(clamType) = featureSums(clamType) / labelCounts(clamType);
            
            % Plot the average feature vector
            figure;
            bar(featureMeans(clamType));
            title(sprintf('Average GLCM Feature Vector for %s', clamType));
            xlabel('Feature Index');
            ylabel('Value');
            
            % Save the figure as a PNG file
            saveas(gcf, fullfile(savePath, sprintf('GLCM_AverageFeatureVector_%s.png', clamType)));
            close(gcf); % Close the figure
        end
    end
    
    % Normalize the features (optional, depends on further use)
    features = normalize(cell2mat(values(featureMeans)), 'range');
    
    % Create a table to store the features and labels (only mean features)
    glcmFeatures = array2table(features, 'VariableNames', {'MeanContrast', 'StdContrast', ...
                                                           'MeanCorrelation', 'StdCorrelation', ...
                                                           'MeanEnergy', 'StdEnergy', ...
                                                           'MeanHomogeneity', 'StdHomogeneity'});
    glcmFeatures.Label = keys(featureMeans);
    
    % Save the table to a MAT file
    save(fullfile(savePath, 'glcmFeatures.mat'), 'glcmFeatures');
    disp(['GLCM average features data saved to ', fullfile(savePath, 'glcmFeatures.mat')]);
end

