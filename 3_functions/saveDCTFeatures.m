function saveDCTFeatures(imds, savePath)
    disp('The process is ongoing, please be patient...');
    block = 3;
    
    numImages = numel(imds.Files);
    
    % Initialize containers to store features and labels
    dctFeatures = zeros(numImages, block^2);  % Preallocate matrix for features
    labels = cell(numImages, 1);  % Initialize as cell array for labels
    
    for i = 1:numImages
        img = readimage(imds, i);
        label = imds.Labels(i); % Get the label for the current image
        labels{i} = char(label); % Convert to char for saving in table
        
        grayImage = rgb2gray(img);

        % Compute the 2D Discrete Cosine Transform
        dctImage = dct2(double(grayImage));
        
        % Extract top-left corner DCT coefficients 
        dctBlock = dctImage(1:block, 1:block);
        
        % Convert the DCT block to a feature vector and store it
        dctFeatures(i, :) = dctBlock(:)';
    end
    
    % Convert the features matrix and labels to a table
    dctFeatures = array2table(dctFeatures, 'VariableNames', compose('DCTCoeff_%d', 1:block^2));
    dctFeatures.Label = labels;
    
    % Save the table to a MAT file
    save(fullfile(savePath, 'dctFeatures.mat'), 'dctFeatures');
    disp(['DCT features data saved to ', fullfile(savePath, 'dctFeatures.mat')]);
end
