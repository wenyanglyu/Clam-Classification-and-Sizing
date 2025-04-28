% Vernier measured values
vernier_measured = [
    33.60, 33.60, 33.60, 33.60, 54.00, 54.00, 54.00, 54.00, 56.10, 56.10, ...
    65.30, 65.30, 68.50, 68.50, 68.50, 68.50, 68.30, 68.30, 68.30, 68.30, ...
    90.70, 90.70, 90.70, 90.70
];

% Scaled sizes
scaled_sizes = [
    35.51, 35.73, 35.98, 36.20, 54.65, 54.69, 54.78, 54.82, 55.75, 56.17, ...
    65.72, 66.01, 67.28, 67.64, 67.75, 67.89, 68.51, 68.60, 68.86, 68.98, ...
    88.21, 88.28, 88.30, 89.88
];

% Create a plot
figure;
hold on;

% Plot the data points for Vernier vs. Scaled
plot(vernier_measured, scaled_sizes, 'go', 'MarkerSize', 7, 'MarkerFaceColor', 'g', 'DisplayName', 'Scaled Sizes');

% Plot the dashed blue reference line (y = x)
plot([min(vernier_measured), max(vernier_measured)], [min(vernier_measured), max(vernier_measured)], 'b--', 'LineWidth', 1.5, 'DisplayName', 'Reference Line');

% Labels and Title
xlabel('Vernier Measured Diameters (mm)', 'FontSize', 14);
ylabel('Scaled Diameters (mm)', 'FontSize', 14);

% Add legend
legend('Location', 'best', 'FontSize', 12);

% Show grid
grid on;

% Hold off to stop adding to this plot
hold off;

% Show the plot
