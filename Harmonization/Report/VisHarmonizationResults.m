function VisHarmonizationResults(Data_beforeHarmonization, Data_afterHarmonization, SiteLabel, savepath)

% Draw harmonization results comparing data before and after harmonization
%
% Inputs:
%   Data_beforeHarmonization - Data matrix before harmonization
%   Data_afterHarmonization - Data matrix after harmonization
%   SiteLabel - Cell array of site labels
%   savepath - Path to save the output figures

% Convert SiteLabel to cell array if necessary
if ~iscell(SiteLabel)
    SiteLabel = all2cellstring(SiteLabel);
end

% Get unique site names
SiteName = unique(SiteLabel);

% Draw PCA plots
drawPCAPlots(Data_beforeHarmonization, Data_afterHarmonization, SiteLabel, SiteName, savepath);

end


function drawPCAPlots(Data_before, Data_after, SiteLabel, SiteName, savepath)
    % Create PCA plots for before and after harmonization
    fig = figure('Visible','Off','Position', [100 100 1200 600]);
    
    % Before harmonization
    subplot(1, 2, 1);
    PCA(Data_before, SiteLabel, SiteName);
    title('Before Harmonization', 'FontSize', 20, 'FontWeight', 'bold');
    
    % After harmonization
    subplot(1, 2, 2);
    PCA(Data_after, SiteLabel, SiteName);
    title('After Harmonization', 'FontSize', 20, 'FontWeight', 'bold');
    
    % Add legend
    addLegend(SiteName, 'PCA');
    
    % Adjust subplot positions
    set(subplot(1,2,1), 'Position', [0.05 0.1 0.4 0.8]);
    set(subplot(1,2,2), 'Position', [0.5 0.1 0.4 0.8]);
    
    % Save figure
    saveas(fig, fullfile(savepath, 'PCA_plot.png'));
    close(fig);
end

function PCA(Data, SiteLabel, SiteName) 
    % Use PCA to reduce data to 2 dimensions
    [coeff, score, ~, ~, explained, ~] = pca(Data');

    Nsite = length(SiteName);
    colors = Colors(Nsite);

    % Plot PCA results
    hold on;
    for i = 1:Nsite
        ind = strcmp(SiteLabel, SiteName{i});
        site_scores = score(ind, 1:2);
        
        % Plot scatter points
        scatter(site_scores(:, 1), site_scores(:, 2), 50, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        
        % Calculate and plot ellipse
        [e_x, e_y] = calculateEllipse(site_scores(:, 1), site_scores(:, 2));
        plot(e_x, e_y, 'Color', colors(i,:), 'LineWidth', 2);
    end

    xlabel_str = sprintf('PCA 1 (%.1f%% variation explained)', round(explained(1), 1));
    ylabel_str = sprintf('PCA 2 (%.1f%% variation explained)', round(explained(2), 1));

    xlabel(xlabel_str, 'FontSize', 16);
    ylabel(ylabel_str, 'FontSize', 16);

    set(gca, ...
        'LineWidth', 1.5, ...
        'YMinorTick', 'off', 'TickDir', 'out', ...
        'XMinorTick', 'off', 'TickDir', 'out', ...
        'FontSize', 13);
        
    hold off;
end

function [e_x, e_y] = calculateEllipse(x, y)
    % Calculate the covariance matrix
    covariance = cov(x, y);
    
    % Calculate eigenvalues and eigenvectors
    [eigenvec, eigenval] = eig(covariance);
    
    % Get the index of the largest eigenvalue
    [~, max_ind] = max(diag(eigenval));
    
    % Get the largest eigenvector and eigenvalue
    largest_eigenvec = eigenvec(:, max_ind);
    largest_eigenval = eigenval(max_ind, max_ind);
    
    % Calculate the angle between the x-axis and the largest eigenvector
    angle = atan2(largest_eigenvec(2), largest_eigenvec(1));
    
    % Calculate the 95% confidence interval
    chisquare_val = 2.4477;
    theta_grid = linspace(0, 2*pi);
    phi = angle;
    X0 = mean(x);
    Y0 = mean(y);
    a = chisquare_val * sqrt(largest_eigenval);
    b = chisquare_val * sqrt(eigenval(3-max_ind, 3-max_ind));
    
    % Parametric equation of the ellipse
    e_x = X0 + a*cos(theta_grid)*cos(phi) - b*sin(theta_grid)*sin(phi);
    e_y = Y0 + a*cos(theta_grid)*sin(phi) + b*sin(theta_grid)*cos(phi);
end

function addLegend(SiteName, plotType)
    % Add custom legend to the current figure
    c = Colors(length(SiteName));
    
    hold on;
    h = zeros(length(SiteName), 1);
    for i = 1:length(SiteName)
        if strcmp(plotType, 'density')
            h(i) = patch(nan,nan, c(i,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        elseif strcmp(plotType, 'PCA')
            h(i) = scatter(nan, nan, 150, 'MarkerFaceColor', c(i,:), 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        end
    end
    hold off;
    
    % Create legend
    lgd = legend(h, SiteName, 'Location', 'eastoutside');
    
    % Set legend properties
    lgd.FontSize = 10;
    lgd.Title.String = 'Color-SiteID';
    lgd.Title.FontSize = 15;
    lgd.Title.FontWeight = 'normal';
    lgd.Box = 'off';
    lgd.Color = [1 1 0.8];
end

%--------------------C O L O R-------------------------
function colors4group = Colors(ngroup)
    % Define a set of distinct base colors
    base_colors = [
        0, 0.4470, 0.7410;  % dark blue
        0.8500, 0.3250, 0.0980; % dark orange
        0.9290, 0.6940, 0.1250; % dark yellow
        0.4940, 0.1840, 0.5560; % dark purple
        0.4660, 0.6740, 0.1880; % dark green
        0.3010, 0.7450, 0.9330; % light blue
        0.6350, 0.0780, 0.1840; % dark red
    ];
    
    if ngroup <= size(base_colors, 1)
        % If we need fewer colors than base colors, just return the first ngroup colors
        colors4group = base_colors(1:ngroup, :);
    else
        % If we need more colors, generate them using color interpolation
        colors4group = interpolate_colors(base_colors, ngroup);
    end
end

function colors = interpolate_colors(base_colors, n)
    % Convert base colors to HSV color space
    hsv_colors = rgb2hsv(base_colors);
    
    % Interpolate in HSV space
    h = interp1(linspace(0, 1, size(base_colors, 1)), hsv_colors(:, 1), linspace(0, 1, n), 'pchip');
    s = interp1(linspace(0, 1, size(base_colors, 1)), hsv_colors(:, 2), linspace(0, 1, n), 'pchip');
    v = interp1(linspace(0, 1, size(base_colors, 1)), hsv_colors(:, 3), linspace(0, 1, n), 'pchip');
    
    % Convert back to RGB
    colors = hsv2rgb([h' s' v']);
    
    % Ensure colors are visually distinct
    colors = adjust_colors(colors);
end

function colors = adjust_colors(colors)
    % Adjust colors to ensure they are visually distinct
    for i = 2:size(colors, 1)
        while sum(pdist2(colors(i, :), colors(1:i-1, :)) < 0.2) > 0
            colors(i, :) = colors(i, :) + randn(1, 3) * 0.1;
            colors(i, :) = min(max(colors(i, :), 0), 1);  % Ensure values are between 0 and 1
        end
    end
end