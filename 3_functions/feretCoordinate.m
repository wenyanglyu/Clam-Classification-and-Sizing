function results = feretCoordinate(origDir, destDir)
    if ~isfolder(destDir)
        mkdir(destDir);
    end
    
    % Get all image files directly in the original directory
    imageFiles = dir(fullfile(origDir, '*.JPG'));
    
    results = zeros(length(imageFiles), 4);  % Initialize results as a zeros array
    
    for imgIndex = 1:length(imageFiles)
        imagePath = fullfile(origDir, imageFiles(imgIndex).name);
        rgbImage = imread(imagePath);
        hsvImage = rgb2hsv(rgbImage);  % Convert the image to HSV color space
        
        % Assume we're examining the top edge of the image as a sample of the background
        edgeWidth = 10;  % You can adjust this width as necessary
        backgroundRegion = hsvImage(1:edgeWidth, :, 1);  % Select the hue channel of the top edge
        % Calculate statistical data for the hue values in the background region
        meanHue = mean(backgroundRegion, 'all');  % Calculate the mean hue value
        stdHue = std(double(backgroundRegion), [], 'all');  % Calculate the standard deviation of hue
        
        % Set the threshold for all images
        threshold = [meanHue - 4*stdHue, meanHue + 4*stdHue];
        
        % Create a mask to exclude the background based on the hue threshold
        mask = hsvImage(:,:,1) > threshold(1) & hsvImage(:,:,1) < threshold(2);

        % Apply the mask to the original image
        HUEHighlightenedImg = bsxfun(@times, rgbImage, cast(~mask, class(rgbImage)));
        
        % Draw the Feret Diameter on Cropped Image
        invertedImage = imcomplement(HUEHighlightenedImg);
        grayImage = rgb2gray(invertedImage);
        thresholdValue = 225;
        mask1 = grayImage < thresholdValue;
        
        % Fill the blobs
        mask2 = imfill(mask1, 'holes');
        % Take the largest blob only
        mask = bwareafilt(mask2, 1);
        props = regionprops(mask, 'MaxFeretProperties');
        
        % Save the coordinates
        if ~isempty(props)
            xMax = props.MaxFeretCoordinates(:, 1);
            yMax = props.MaxFeretCoordinates(:, 2);
            % Ensure that the coordinates are in the correct order for saving
            results(imgIndex, :) = [xMax(1), yMax(1), xMax(2), yMax(2)];
        end
    end
    
    % Save the results to a .mat file
    save(fullfile(destDir, 'feretCoordinates.mat'), 'results');
end
