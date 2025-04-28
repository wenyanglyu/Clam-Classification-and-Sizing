function saveAlexNetFeatures(imds, savePath)
    net = alexnet;
    targetSize = net.Layers(1).InputSize(1:2);  % Extract the input size for AlexNet

    numImages = numel(imds.Files);
    features = [];
    labels = cell(numImages, 1);  % Initialize as cell array

    % Augmented image datastore for resizing images to match AlexNet input size
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
        alexFeatures = activations(net, imgResized, 'fc7', 'OutputAs', 'channels');
        alexFeatures = squeeze(mean(alexFeatures, [1 2]));  % Average over spatial dimensions

        % Collect all features
        features = [features; alexFeatures'];
    end

    % Create a table to store the features and labels
    alexNetFeatures = array2table(features, 'VariableNames', compose('AlexNetFeature_%d', 1:size(features, 2)));
    alexNetFeatures.Label = labels;

    % Save the table to a MAT file
    save(fullfile(savePath, 'alexNetFeatures.mat'), 'alexNetFeatures');
    disp(['AlexNet features data saved to ', fullfile(savePath, 'alexNetFeatures.mat')]);
end

