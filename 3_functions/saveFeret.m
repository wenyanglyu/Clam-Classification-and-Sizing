function saveFeret(imds, savePath)
    % Calculate the maximum feret diameter, minimum feret diameter, min/max ratio, and area size
    % for each image in the imageDatastore and save with labels.
    
    numImages = numel(imds.Files);
    maxFeretDiameters = zeros(numImages, 1);
    minFeretDiameters = zeros(numImages, 1);
    areas = zeros(numImages, 1);
    minMaxRatios = zeros(numImages, 1);
    labels = cell(numImages, 1); % Store labels
    
    for i = 1:numImages
        img = readimage(imds, i);
        label = imds.Labels(i); % Get the label for the current image
        labels{i} = char(label); % Convert to char for saving in table
        
        hsvImage = rgb2hsv(img);  % Convert the image to HSV color space

        % Assume we're examining the top edge of the image as a sample of the background
        edgeWidth = 10;  % You can adjust this width as necessary
        backgroundRegion = hsvImage(1:edgeWidth, :, 1);  % Select the hue channel of the top edge
        % Calculate statistical data for the hue values in the background region
        meanHue = mean(backgroundRegion, 'all');  % Calculate the mean hue value
        stdHue = std(double(backgroundRegion), [], 'all');  % Calculate the standard deviation of hue
        
        % Set the threshold for all images
        threshold = [meanHue - 2*stdHue, meanHue + 2*stdHue];
        
        % Create a mask to exclude the background based on the hue threshold
        mask = hsvImage(:,:,1) > threshold(1) & hsvImage(:,:,1) < threshold(2);

        % Apply the mask to the original image
        HUEHighlightenedImg = bsxfun(@times, img, cast(~mask, class(img)));
        
        % Draw the Feret Diameter on Cropped Image
        invertedImage = imcomplement(HUEHighlightenedImg);
        grayImage = rgb2gray(invertedImage);
        thresholdValue = 225;
        mask1 = grayImage < thresholdValue;
        
        % Fill the blobs
        mask2 = imfill(mask1, 'holes');
        % Take the largest blob only, handling ties
        try
            mask = bwareafilt(mask2, 1);
        catch
            % In case of ties, select the first largest component manually
            props = regionprops(mask2, 'Area', 'PixelIdxList');
            [~, maxIdx] = max([props.Area]);
            mask = false(size(mask2));
            mask(props(maxIdx).PixelIdxList) = true;
        end
        
        % Calculate properties using regionprops
        props = regionprops(mask, 'Area', 'MaxFeretProperties', 'MinFeretProperties');
        
        if ~isempty(props)
            % Assuming the largest connected component is the shell
            maxFeretDiameters(i) = props.MaxFeretDiameter;
            minFeretDiameters(i) = props.MinFeretDiameter;
            areas(i) = props.Area;
            minMaxRatios(i) = minFeretDiameters(i) / maxFeretDiameters(i);
        else
            % Set properties to zero if no properties are found
            maxFeretDiameters(i) = 0;
            minFeretDiameters(i) = 0;
            areas(i) = 0;
            minMaxRatios(i) = 0;
        end
    end
    
    % Normalize the features (excluding min/max ratio)
    maxFeretDiameters = (maxFeretDiameters - min(maxFeretDiameters)) / (max(maxFeretDiameters) - min(maxFeretDiameters));
    minFeretDiameters = (minFeretDiameters - min(minFeretDiameters)) / (max(minFeretDiameters) - min(minFeretDiameters));
    areas = (areas - min(areas)) / (max(areas) - min(areas));
    
    % Create a table to store the results
    feretFeatures = table(maxFeretDiameters, minFeretDiameters, areas, minMaxRatios, labels, ...
                          'VariableNames', {'MaxFeretDiameter', 'MinFeretDiameter', 'Area', 'MinMaxRatio', 'Label'});
    
    % Save the table to a MAT file
    save(fullfile(savePath, 'feretFeatures.mat'), 'feretFeatures');
end

