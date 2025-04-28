function annotate_images(origDir, cropLabelFeretDiameter)
    % Get all image files directly in the original directory
    imageFiles = dir(fullfile(origDir, '*.JPG'));
    
    % Define colors for different categories
    categoryColors = containers.Map({'others'}, {'red'});
    defaultColor = 'blue';  % Default color for all categories except 'others'
    
    for imgIndex = 1:numel(imageFiles)
        % Read the original image
        im = imread(fullfile(origDir, imageFiles(imgIndex).name));
        
        % Get the coordinates and labels for this image
        coordsAndLabels = cropLabelFeretDiameter{imgIndex};
        
        % Annotate each region
        for j = 1:size(coordsAndLabels, 1)
            cropX = coordsAndLabels{j, 1};
            cropY = coordsAndLabels{j, 2};
            label = coordsAndLabels{j, 3};
            feretX1 = coordsAndLabels{j, 4} + cropX;
            feretY1 = coordsAndLabels{j, 5} + cropY;
            feretX2 = coordsAndLabels{j, 6} + cropX;
            feretY2 = coordsAndLabels{j, 7} + cropY;
            diameter = coordsAndLabels{j, 8};
            
            % Adjust the size and position of the bounding box as needed
            roi = [cropX - 10, cropY - 10, 100, 100];
            
            % Validate the ROI coordinates
            if all(isfinite(roi)) && all(roi >= 0)
                % Get color for the category, use default if not found
                if isKey(categoryColors, label)
                    color = categoryColors(label);
                else
                    color = defaultColor;
                end
                
                % Draw the bounding box
                im = insertShape(im, 'Rectangle', roi, 'Color', color, 'LineWidth', 1);
                
                % Annotate the label and diameter (if applicable)
                position = [roi(1), roi(2) - 200];
                %if strcmp(label, 'others')
                if strcmp(label, 'othersxxx')
                    im = insertText(im, position, label, 'TextColor', 'white', 'BoxColor', color, 'FontSize', 120);
                else
                    annotationText = sprintf('%s: %.2f mm', label, diameter);
                    im = insertText(im, position, annotationText, 'TextColor', 'white', 'BoxColor', color, 'FontSize', 120);
                    
                    % Validate feret coordinates before drawing the line
                    if all(isfinite([feretX1, feretY1, feretX2, feretY2])) && all([feretX1, feretY1, feretX2, feretY2] >= 0)
                        % Draw a red line between the coordinates of max feret diameter
                        im = insertShape(im, 'Line', [feretX1, feretY1, feretX2, feretY2], 'Color', 'red', 'LineWidth', 20);
                    else
                        warning('Invalid feret coordinates for image %d, region %d.', imgIndex, j);
                    end
                end
            else
                warning('Invalid ROI coordinates for image %d, region %d.', imgIndex, j);
            end
        end
        
        % Display the annotated image
        figure;
        imshow(im);
        title(['Annotated Image ' num2str(imgIndex)]);
    end
end