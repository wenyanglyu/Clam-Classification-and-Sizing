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

% Define different scaling factors for bubble sizes
scaling_factors = [10000, 5000, 2000]; % AlexNet, ResNet, NasNet

% Plot the data using bubbles
figure;
hold on;

% Use different colors for each network
colors = {[0.8500, 0.3250, 0.0980], [0.4660, 0.6740, 0.1880], [0, 0.4470, 0.7410]};  % Custom colors for AlexNet, ResNet, NasNet

for i = 1:size(accuracy, 2)
    % Apply different scaling factors for each network
    bubble_size = time_per_100_images(:, i) / max(time_per_100_images(:)) * scaling_factors(i);
    
    scatter(time_per_100_images(:, i), accuracy(:, i), bubble_size, colors{i}, 'o', ...
        'filled', 'MarkerEdgeColor', 'k', 'DisplayName', network_labels{i}, 'LineWidth', 1.5);
end

% Customize the plot
xlabel('Classification time taken for 100 images (s)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Classification accuracy (%)', 'FontSize', 14, 'FontWeight', 'bold');

% Increase legend size
legend('Location', 'best', 'FontSize', 20, 'FontWeight', 'bold');

grid on;
set(gca, 'FontSize', 17, 'LineWidth', 1.5, 'Box', 'on');

hold off;
