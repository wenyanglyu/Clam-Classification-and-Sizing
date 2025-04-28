function diameters = calculateRealWorldDiameters(cameraParams, cropLabelFeret)
    numImages = numel(cropLabelFeret);
    diameters = zeros(numImages * 6, 1);  % Preallocate for 18 coordinates

    diameterIndex = 1;

    for i = 1:numImages
        % Extract all information for this image
        imageData = cropLabelFeret{i};
        
        for j = 1:size(imageData, 1)
            % Extract crop coordinates and feret coordinates
            cropX = imageData{j, 1};
            cropY = imageData{j, 2};
            feretX1 = imageData{j, 4};
            feretY1 = imageData{j, 5};
            feretX2 = imageData{j, 6};
            feretY2 = imageData{j, 7};
            
            % Check if any of the feret coordinates are NaN
            if isnan(feretX1) || isnan(feretY1) || isnan(feretX2) || isnan(feretY2)
                % Skip this iteration if any feret coordinate is NaN
                continue;
            end

            % Adjust feret coordinates to map to the original image
            adjustedX1 = feretX1 + cropX;
            adjustedY1 = feretY1 + cropY;
            adjustedX2 = feretX2 + cropX;
            adjustedY2 = feretY2 + cropY;

            % Combine adjusted coordinates into image points
            imagePoints = [adjustedX1, adjustedY1; adjustedX2, adjustedY2]; % x, y

            % Map Points to World coordinates using camera parameters
            worldPoints = pointsToWorld(cameraParams, cameraParams.RotationMatrices(:,:,1), ...
                                        cameraParams.TranslationVectors(1,:), imagePoints);

            % Calculate the distance in real world
            d = worldPoints(2, :) - worldPoints(1, :);
            diameterInMillimeters = hypot(d(1), d(2));

            % Store the calculated diameter in mm
            diameters(diameterIndex) = diameterInMillimeters;
            diameterIndex = diameterIndex + 1;
        end
    end

    % Remove any unused preallocated space in the diameters array
    diameters = diameters(1:diameterIndex-1);

    return
end
