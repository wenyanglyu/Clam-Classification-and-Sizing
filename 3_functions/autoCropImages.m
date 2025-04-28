function results = autoCropImages(shellNumber, sourceDir, destDir)
    % Ensure the destination directory exists
    if ~isfolder(destDir)
        mkdir(destDir);
    end
    
    % Define the valid subfolder names for classification
    validFolders = {'Cockle', 'Dosinia', 'Mussel', 'Pebble', 'Tuatua'};
    
    % Initialize the results cell array
    results = {};
    
    % Iterate through each valid subfolder
    for folderIdx = 1:numel(validFolders)
        subfolderName = validFolders{folderIdx};
        subfolderPath = fullfile(sourceDir, subfolderName);
        
        % Check if the subfolder exists
        if isfolder(subfolderPath)
            % Get all image files within the current subfolder
            imageFiles = dir(fullfile(subfolderPath, '*.JPG'));
            
            % Preallocate the results for this subfolder
            folderResults = cell(numel(imageFiles), 1);
            
            for imgIndex = 1:numel(imageFiles)
                % Read the image
                im = imread(fullfile(subfolderPath, imageFiles(imgIndex).name));
                
                % Convert the image to HSV and threshold based on saturation
                imHSV = rgb2hsv(im);
                saturation = imHSV(:, :, 2);
                t = graythresh(saturation);
                imShell = (saturation < t);
                
                % Perform blob analysis to find the clams
                blobAnalysis = vision.BlobAnalysis('AreaOutputPort', true, ...
                    'CentroidOutputPort', false, ...
                    'BoundingBoxOutputPort', true, ...
                    'MinimumBlobArea', 50000, 'ExcludeBorderBlobs', true);
                [areas, boxes] = step(blobAnalysis, imShell);
                
                % Sort and select the largest blobs
                [~, idx] = sort(areas, 'descend');
                numShellsToDisplay = min(numel(areas), shellNumber);
                boxes = double(boxes(idx(1:numShellsToDisplay), :));
                
                % Preallocate coordinates for the current image
                tempResults = NaN(shellNumber, 2);
                
                % Crop and save each detected clam
                for i = 1:numShellsToDisplay
                    roi = [boxes(i, 1)-10, boxes(i, 2)-10, boxes(i, 3)+20, boxes(i, 4)+20];
                    croppedImage = imcrop(im, roi);
                    [~, name, ext] = fileparts(imageFiles(imgIndex).name);
                    croppedFileName = sprintf('%s_%d%s', name, i, ext);
                    croppedFolderPath = fullfile(destDir, subfolderName);
                    
                    % Ensure the destination subfolder exists
                    if ~isfolder(croppedFolderPath)
                        mkdir(croppedFolderPath);
                    end
                    
                    % Save the cropped image in the corresponding subfolder
                    imwrite(croppedImage, fullfile(croppedFolderPath, croppedFileName));
                    
                    % Store the coordinates
                    xCrop = roi(1);
                    yCrop = roi(2);
                    tempResults(i, :) = [xCrop, yCrop];
                end
                
                % Store the results for the current image
                folderResults{imgIndex} = tempResults;
            end
            
            % Append the results for this subfolder to the overall results
            results = [results; folderResults];
        end
    end
    
    % Display the coordinates for each image
    disp('Coordinates for each image:');
    for imgIndex = 1:numel(results)
        fprintf('Image %d:\n', imgIndex);
        disp(results{imgIndex});
    end
end
