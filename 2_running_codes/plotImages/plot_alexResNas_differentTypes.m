% Define the data from the table
accuracy = [
    83, 86, 92;  % 9am Indoor
    89, 94, 94;  % 11am Indoor
    97, 100, 99; % 12pm Indoor
    92, 98, 97   % 12pm Outdoor
];

time = [
    5.65, 22.16, 176.41;  % 9am Indoor
    5.99, 19.92, 237.91;  % 11am Indoor
    6.98, 56.04, 281.41;  % 12pm Indoor
    10.88, 55.50, 271.34  % 12pm Outdoor
];

% Convert time to time per 100 images
time_per_100_images = time * 1;

% Define the labels for each network
network_labels = {'AlexNet', 'ResNet50', 'NasNet-Large'};

% Define different marker sizes for each network
marker_sizes = [200, 300, 400]; % AlexNet, ResNet, NasNet

% Plot the data using larger markers
figure;
hold on;

% Use different colors for each network
colors = {[0.8500, 0.3250, 0.0980], [0.4660, 0.6740, 0.1880], [0, 0.4470, 0.7410]};  % Custom colors for AlexNet, ResNet, NasNet

% Plot the data with different markers
scatter(time_per_100_images(:, 1), accuracy(:, 1), marker_sizes(1), colors{1}, ...
    'filled', 'MarkerEdgeColor', 'k', 'Marker', 'o', 'DisplayName', network_labels{1}, 'LineWidth', 1.5); % Circle for AlexNet
scatter(time_per_100_images(:, 2), accuracy(:, 2), marker_sizes(2), colors{2}, ...
    'filled', 'MarkerEdgeColor', 'k', 'Marker', '^', 'DisplayName', network_labels{2}, 'LineWidth', 1.5); % Triangle for ResNet50
scatter(time_per_100_images(:, 3), accuracy(:, 3), marker_sizes(3), colors{3}, ...
    'filled', 'MarkerEdgeColor', 'k', 'Marker', 's', 'DisplayName', network_labels{3}, 'LineWidth', 1.5); % Square for NasNet-Large

% Customize the plot
xlabel('Classification time taken for 100 images (s)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Classification accuracy (%)', 'FontSize', 14, 'FontWeight', 'bold');

% Create a legend and set a larger marker size for visibility
legend_handle = legend('Location', 'best', 'FontSize', 20, 'FontWeight', 'bold');
set(findobj(legend_handle, 'type', 'line'), 'MarkerSize', 40); % Increase the size of the legend markers

grid on;
set(gca, 'FontSize', 17, 'LineWidth', 1.5, 'Box', 'on');

hold off;
