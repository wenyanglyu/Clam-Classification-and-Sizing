%% Data from the previous code
tc = [176.41 237.91 281.41 271.34];  % NasNet-Large
Ac = [92, 94, 97, 99];
ta = [5.65, 5.99, 6.98, 10.88];  % AlexNet
Aa = [83, 89, 97, 92];
tb = [22.16, 19.92, 56.04, 55.50];  % ResNet50
Ab = [86, 94, 100, 98];

% Plot using semilogx
clf;
h = semilogx(ta, Aa, tb, Ab, tc, Ac, 's');
set(h(1), 'Marker', 'o', 'MarkerFaceColor', [1 0.5 0], 'LineStyle', 'none');  % Orange for AlexNet
set(h(2), 'Marker', '>', 'MarkerFaceColor', [0 1 0], 'Color', 'k', 'LineStyle', 'none');  % Green for ResNet50
set(h(3), 'Marker', 's', 'MarkerFaceColor', [0.53 0.81 0.98], 'Color', 'k', 'LineStyle', 'none');  % Sky blue for NasNet-Large

% Fit lines and plot
xa = linspace(1, 200)';
pa = polyfit(ta, Aa, 1); 
ysa = polyval(pa, xa);
ysa = min(ysa, 100);  % Limit values to 100

xb = linspace(1, 300)';
pb = polyfit(tb, Ab, 1); 
ysb = polyval(pb, xb);
ysb = min(ysb, 100);  % Limit values to 100

xc = linspace(167, 300)';
pc = polyfit(tc, Ac, 2); 
ysc = polyval(pc, xc);
ysc = min(ysc, 100);  % Limit values to 100

hold on;
hs = plot(xa, ysa, xb, ysb, xc, ysc, '-');
set(hs(1), 'Color', [1 0.75 0.79]);  % Pink line for AlexNet
set(hs(2), 'Color', [0.47 0.67 0.19]);  % Green line for ResNet50
set(hs(3), 'Color', [0 0.45 0.74]);  % Sky blue line for NasNet-Large

% Horizontal line at accuracy 100%
yline(100, '--');

% Adjust the limits and labels
ylim([70 103]);
% Set the legend with custom font size and location
legend_handle = legend([h(1), h(2), h(3)], 'AlexNet', 'ResNet50', 'NasNet-Large', ...
    'Location', 'southeast');
set(legend_handle, 'FontSize', 12);  % Set font size of the legend

xlabel('Classification time taken for 100 images [s]', 'FontSize', 14);
ylabel('Accuracy [%]', 'FontSize', 14);

% Add grid
grid on;
hold off;
