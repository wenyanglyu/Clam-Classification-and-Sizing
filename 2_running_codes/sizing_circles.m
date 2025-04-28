% Set up directory paths
SourceDir = 'D:/Clam_Classify_Sizing/';
imgDir = fullfile(SourceDir, '1_images');
funcDir = fullfile(SourceDir, '3_functions');
saveDir = fullfile(SourceDir, '4_saved_files');
addpath(genpath(funcDir));

% Load the camera parameters from saveDir
cameraParamsFile = fullfile(saveDir, 'cameraParams.mat');
load(cameraParamsFile, 'cameraParams');

% Get a list of all JPG files in the circlesImgDir directory
circlesImgDir = fullfile(imgDir, '2_sizing', '2_circles');
imageFiles = dir(fullfile(circlesImgDir, '*.JPG'));

% Initialize a cell array to hold the results
results = {};

% Loop through all JPG files in the directory
for k = 1:length(imageFiles)
    % Load the current image
    imageFile = fullfile(circlesImgDir, imageFiles(k).name);
    I_original = imread(imageFile);

    % **Step 1: Undistort the image to correct lens distortion**
    I_undistorted = undistortImage(I_original, cameraParams);

    % Convert the undistorted image to grayscale
    I_gray = rgb2gray(I_undistorted);

    % Threshold the image to create a binary image
    bw = imbinarize(I_gray, 'adaptive', 'Sensitivity', 0.4);

    % Use morphological operations to clean up the image
    bw = imopen(bw, strel('disk', 5)); % Remove small objects
    bw = imclose(bw, strel('disk', 10)); % Close gaps in the objects

    % Create a blob analysis object
    blobAnalyzer = vision.BlobAnalysis('MinimumBlobArea', 100000, 'MaximumBlobArea', 1000000, ...
        'BoundingBoxOutputPort', true, 'MajorAxisLengthOutputPort', true, 'MinorAxisLengthOutputPort', true);

    % Detect blobs
    [~, centroids, bboxes, majorAxis, minorAxis] = blobAnalyzer(bw);

    % Filter blobs by circularity (keep only blobs that are roughly circular)
    circularityThreshold = 0.5; % Adjust this threshold as needed
    circularBlobsIdx = (minorAxis ./ majorAxis) > circularityThreshold;

    % Get the centroids and bounding boxes of the circular blobs
    circularCentroids = centroids(circularBlobsIdx, :);
    circularBboxes = bboxes(circularBlobsIdx, :);

    % Draw the detected circular blobs on the undistorted image and calculate distances
    figure(1); % Create a new figure for the final annotated image with real-world distances
    imshow(I_undistorted);
    hold on;

    for i = 1:size(circularCentroids, 1)
        % Get the centroid and bounding box of the current blob
        centroid = circularCentroids(i, :);
        bbox = circularBboxes(i, :);

        % Calculate the top and bottom points of the vertical diameter
        topPoint = [centroid(1), centroid(2) - bbox(4)/2];
        bottomPoint = [centroid(1), centroid(2) + bbox(4)/2];

        % Map points to world coordinates using camera parameters
        imagePoints = [topPoint; bottomPoint]; % [x, y] pairs
        worldPoints = pointsToWorld(cameraParams, cameraParams.RotationMatrices(:,:,1), ...
                                    cameraParams.TranslationVectors(1,:), imagePoints);

        % Calculate the real-world distance between the top and bottom points
        realDistance = sqrt(sum((worldPoints(1, :) - worldPoints(2, :)).^2));

        % Annotate the real-world distance on the image
        text(centroid(1) + 10, centroid(2), sprintf('%.2f mm', realDistance), 'Color', 'red', 'FontSize', 12);

        % Annotate the diameter line on the image
        plot([topPoint(1), bottomPoint(1)], [topPoint(2), bottomPoint(2)], 'r-', 'LineWidth', 2);

        % Append the result to the results cell array
        results = [results; {imageFiles(k).name, realDistance}];
    end

    hold off;

    % Save the annotated image
    [~, name, ~] = fileparts(imageFiles(k).name);
    saveas(gcf, fullfile(saveDir, [name '_annotated.png']));

    % Close the figure
    close(gcf);
end

% Convert the results cell array to a table and write to a CSV file
resultsTable = cell2table(results, 'VariableNames', {'FileName', 'Diameter'});
writetable(resultsTable, fullfile(saveDir, 'clams_diameter_results.csv'));

