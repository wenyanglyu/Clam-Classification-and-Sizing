function saveNasNetFeatures(imds, savePath)
    disp('The process is ongoing, please be patient...');
    
    % Load the NASNet-Large network
    net = nasnetlarge;
    targetSize = [331 331];  % Correct input size for NASNet-Large

    numImages = numel(imds.Files);
    features = [];
    labels = cell(numImages, 1);  % Initialize as cell array

    % Augmented image datastore for resizing images to match NASNet-Large input size
    augimds = augmentedImageDatastore(targetSize, imds, 'ColorPreprocessing', 'gray2rgb');

    % Read each batch of images and extract features
    for i = 1:numImages
        img = readimage(imds, i);
        label = imds.Labels(i); % Get the label for the current image
        labels{i} = char(label); % Convert to char for saving in table

        % Resize image to the target size for NASNet-Large
        imgResized = imresize(img, targetSize);

        % Ensure the image has 3 color channels
        if size(imgResized, 3) == 1
            imgResized = repmat(imgResized, [1 1 3]);
        end

        % Compute the activations from the 'global_average_pooling2d_2' layer
        nasFeatures = activations(net, imgResized, 'global_average_pooling2d_2', 'OutputAs', 'channels');
        nasFeatures = squeeze(nasFeatures);  % Squeeze to remove singleton dimensions

        % Collect all features
        features = [features; nasFeatures'];
    end

    % Create a table to store the features and labels
    nasNetFeatures = array2table(features, 'VariableNames', compose('NASNetFeature_%d', 1:size(features, 2)));
    nasNetFeatures.Label = labels;

    % Save the table to a MAT file
    save(fullfile(savePath, 'nasNetFeatures.mat'), 'nasNetFeatures');
    disp(['NASNet features data saved to ', fullfile(savePath, 'nasNetFeatures.mat')]);
end

