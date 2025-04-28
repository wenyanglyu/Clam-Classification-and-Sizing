function saveResNetFeatures(imds, savePath)
    disp('The process is ongoing, it takes about a blink of an eye');
    net = resnet50;
    targetSize = [224 224];  % Corrected size for ResNet50

    numImages = numel(imds.Files);
    features = [];
    labels = cell(numImages, 1);  % Initialize as cell array

    % Augmented image datastore for resizing images to match ResNet50 input size
    augimds = augmentedImageDatastore(targetSize, imds, 'ColorPreprocessing', 'gray2rgb');

    % Read each batch of images and extract features
    for i = 1:numImages
        img = readimage(imds, i);
        label = imds.Labels(i); % Get the label for the current image
        labels{i} = char(label); % Convert to char for saving in table

        % Resize image
        imgResized = imresize(img, targetSize);

        % Ensure the image has 3 color channels
        if size(imgResized, 3) == 1
            imgResized = repmat(imgResized, [1 1 3]);
        end

        % Compute the activations
        resFeatures = activations(net, imgResized, 'avg_pool', 'OutputAs', 'channels');
        resFeatures = squeeze(mean(resFeatures, [1 2]));  % Average over spatial dimensions

        % Collect all features
        features = [features; resFeatures'];
    end

    % Create a table to store the features and labels
    resNetFeatures = array2table(features, 'VariableNames', compose('ResNetFeature_%d', 1:size(features, 2)));
    resNetFeatures.Label = labels;

    % Save the table to a MAT file
    save(fullfile(savePath, 'resNetFeatures.mat'), 'resNetFeatures');
    disp(['ResNet features data saved to ', fullfile(savePath, 'resNetFeatures.mat')]);
end

