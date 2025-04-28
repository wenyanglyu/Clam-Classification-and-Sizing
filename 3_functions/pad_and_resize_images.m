function pad_and_resize_images(sourceDir, dstDir)
    % Create the destination directory if it does not exist
    if ~exist(dstDir, 'dir')
        mkdir(dstDir);
    end
    
    % Get a list of all subfolders in the source directory
    subfolders = dir(sourceDir);
    subfolders = subfolders([subfolders.isdir]);  % Keep only directories
    subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'}));  % Exclude . and ..
    
    targetSize = [224, 224];  % Define the target image size
    targetWidth = targetSize(1);
    targetHeight = targetSize(2);
    
    % Process each subfolder
    for subfolderIdx = 1:length(subfolders)
        subfolderName = subfolders(subfolderIdx).name;
        subfolderPath = fullfile(sourceDir, subfolderName);
        
        % Get a list of all image files in the current subfolder
        imageFiles = dir(fullfile(subfolderPath, '*.JPG'));
        
        % Create the corresponding destination subfolder
        dstSubfolder = fullfile(dstDir, subfolderName);
        if ~exist(dstSubfolder, 'dir')
            mkdir(dstSubfolder);
        end
        
        % Process each image in the subfolder
        for i = 1:length(imageFiles)
            imagePath = fullfile(subfolderPath, imageFiles(i).name);
            img = imread(imagePath);
            
            % Get the padding color from the pixel at (10,10)
            if size(img, 1) >= 10 && size(img, 2) >= 10
                paddingColor = squeeze(img(10, 10, :));
            else
                error('Image is too small to extract padding color from (10,10)');
            end
            
            % Get current image size
            [h, w, d] = size(img);
            
            % Determine new edge length based on the larger dimension
            if h > w
                newEdge = h;
                padLeft = floor((newEdge - w) / 2);
                padRight = ceil((newEdge - w) / 2);
                paddedImg = zeros(newEdge, newEdge, d, 'uint8');
                for c = 1:d
                    paddedChannel = padarray(img(:, :, c), [0, padLeft], paddingColor(c), 'pre');
                    paddedChannel = padarray(paddedChannel, [0, padRight], paddingColor(c), 'post');
                    paddedImg(:, :, c) = paddedChannel;
                end
            else
                newEdge = w;
                padTop = floor((newEdge - h) / 2);
                padBottom = ceil((newEdge - h) / 2);
                paddedImg = zeros(newEdge, newEdge, d, 'uint8');
                for c = 1:d
                    paddedChannel = padarray(img(:, :, c), [padTop, 0], paddingColor(c), 'pre');
                    paddedChannel = padarray(paddedChannel, [padBottom, 0], paddingColor(c), 'post');
                    paddedImg(:, :, c) = paddedChannel;
                end
            end
            
            % Resize the padded image to the target size
            resizedImg = imresize(paddedImg, [targetWidth, targetHeight]);
            
            % Save the processed image to the destination subfolder
            [~, imageName, ext] = fileparts(imageFiles(i).name);
            newImagePath = fullfile(dstSubfolder, [imageName, ext]);
            imwrite(resizedImg, newImagePath);
        end
    end
end
