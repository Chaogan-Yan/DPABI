%% Harmonization report html
function ReportHarmonization(SiteInfo,HarMethod,PicPath,Data_beforeHarmonization, Data_afterHarmonization)
%
% Inputs:
%   SiteInfo                  - Vector containing site information for each sample
%   HarMethod                 - String specifying the harmonization method used
%   PicPath                   - String specifying the path to save output figures
%   Data_beforeHarmonization  - Matrix of data before harmonization (features x samples)
%   Data_afterHarmonization   - Matrix of data after harmonization (features x samples)
%
% Outputs:
%   An HTML report file saved in the specified PicPath, containing:
%     1. Data-Site Distribution
%     2. Harmonization Method
%     3. Harmonization Results
%        3.1 Principal Component Analysis
%        3.2 Statistical Analysis (ANOVA results)
%
% The function also generates and saves several figures:
%   - site_distribution.png: Bar plot of sample distribution across sites
%   - PCA_plot.png: PCA plots before and after harmonization
%   - p_values_plot.png: P-values for each feature before and after harmonization
%
% Note: This function requires the following helper functions:
%   - FileSiteDistribution.m
%   - VisHarmonizationResults.m
%   - performStatisticalAnalysis


disp("======= We are writing a report for you. Please be patient. =======")

%% Harmonization info 
FileNum=length(SiteInfo);
SiteNum=length(unique(SiteInfo));
HarmoizationMethod = HarMethod;

% Generate figures
FileSiteDistribution(SiteInfo, PicPath);
VisHarmonizationResults(Data_beforeHarmonization, Data_afterHarmonization, SiteInfo, PicPath);

% File paths
FileSiteFigure = fullfile(PicPath, 'site_distribution.png');
pcapic = fullfile(PicPath, 'PCA_plot.png');

% Generate HTML report
html_filename = fullfile(PicPath, 'DPABIHarmonization_Report.html');
fid = fopen(html_filename, 'w');

% Perform statistical analysis
stats = performStatisticalAnalysis(Data_beforeHarmonization, Data_afterHarmonization, SiteInfo,PicPath);

% Create the HTML report
fid = fopen(fullfile(PicPath, 'DPABIHarmonization_Report.html'), 'w');
fprintf(fid, '<!DOCTYPE html>\n');
fprintf(fid, '<html lang="en">\n');
fprintf(fid, '<head>\n');
fprintf(fid, '    <meta charset="UTF-8">\n');
fprintf(fid, '    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n');
fprintf(fid, '    <title>DPABI Harmonization Report</title>\n');
fprintf(fid, '    <style>\n');
fprintf(fid, '        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px; }\n');
fprintf(fid, '        h1, h2 { color: #2c3e50; }\n');
fprintf(fid, '        img { max-width: 100%%; height: auto; display: block; margin: 20px auto; }\n');
fprintf(fid, '        .image-caption { text-align: center; font-style: italic; margin-bottom: 20px; }\n');
fprintf(fid, '        .figure1 { max-width: 80%%; }\n');
fprintf(fid, '    </style>\n');
fprintf(fid, '</head>\n');
fprintf(fid, '<body>\n');
fprintf(fid, '    <h1>DPABI Harmonization Report</h1>\n');

fprintf(fid, '    <h2>1. Data-Site Distribution</h2>\n');
fprintf(fid, '    <p>The analysis includes %d files from %d different sites. The distribution of files across sites is illustrated below:</p>\n', FileNum, SiteNum);
fprintf(fid, '    <img src="%s" alt="File-Source(Site) distribution" class="figure1">\n', fullfile(PicPath, 'site_distribution.png'));
fprintf(fid, '    <p class="image-caption">Figure 1: Distribution of files across different sites</p>\n');

fprintf(fid, '    <h2>2. Harmonization Method</h2>\n');
fprintf(fid, '    <p>The %s approach was selected for data harmonization.</p>\n',HarMethod);

fprintf(fid, '    <h2>3. Harmonization Results</h2>\n');
fprintf(fid, '    <h3>3.1 Principal Component Analysis</h3>\n');
fprintf(fid, '    <img src="%s" alt="PCA Plots">\n', fullfile(PicPath, 'PCA_plot.png'));
fprintf(fid, '    <p class="image-caption">Figure 2: Scatter plots of the top 2 principal components after principal component analysis of all data points. Colors distinguish sites.</p>\n');

fprintf(fid, '    <h2>3.2 Statistical Analysis</h2>\n');
fprintf(fid, '    <p>One-way ANOVA was performed to assess the site effect before and after harmonization:</p>\n');
fprintf(fid, '    <ul>\n');
fprintf(fid, '        <li>Before harmonization: p-value = %.4f, effect size (eta-squared) = %.4f</li>\n', stats.p_before, stats.eta_squared_before);
fprintf(fid, '        <li>After harmonization: p-value = %.4f, effect size (eta-squared) = %.4f</li>\n', stats.p_after, stats.eta_squared_after);
fprintf(fid, '    </ul>\n');
fprintf(fid, '    <p>A smaller p-value and larger effect size indicate a stronger site effect. The results show that the harmonization process %s the site effect.</p>\n', conditional(stats.p_after > stats.p_before, 'reduced', 'did not significantly reduce'));
fprintf(fid, '    <img src="%s" alt="Pvalue Plots">\n', fullfile(PicPath, 'p_values_plot.png'));
fprintf(fid, '    <p class="image-caption">Figure 3: P values before and after harmonization of each feature. The red dashed line represents p = 0.01. </p>\n');

fprintf(fid, '</body>\n');
fprintf(fid, '</html>\n');
fclose(fid);

disp("Report finished. Please check it in the output directory.");

end



function stats = performStatisticalAnalysis(Data_before, Data_after, SiteLabel, savepath)
    % Ensure SiteLabel is a column vector
    SiteLabel = SiteLabel(:);
    
    % Check if Data_before or Data_after contains NaN
    if any(isnan(Data_before(:))) || any(isnan(Data_after(:)))
        error('Data_before or Data_after contains NaN values. Please check the input data.');
    end
    
    
    [n_features,n_samples] = size(Data_before);
  
    % Perform ANOVA for each feature
    p_before = zeros(n_features, 1);
    p_after = zeros(n_features, 1);
    eta_squared_before = zeros(n_features, 1);
    eta_squared_after = zeros(n_features, 1);
    
    for i = 1:n_features
        [p_before(i), tbl_before, ~] = anova1(Data_before(i,:), SiteLabel, 'off');
        SS_total_before = sum(cell2mat(tbl_before(2:end, 2)));
        eta_squared_before(i) = tbl_before{2, 2} / SS_total_before;
    end
    
    for i = 1:n_features
        [p_after(i), tbl_after, ~] = anova1(Data_after(i,:), SiteLabel, 'off');
        SS_total_after = sum(cell2mat(tbl_after(2:end, 2)));
        eta_squared_after(i) = tbl_after{2, 2} / SS_total_after;
    end
    
    % Calculate mean p-values and effect sizes
    stats.p_before = mean(p_before, 'omitnan');
    stats.p_after = mean(p_after, 'omitnan');
    stats.eta_squared_before = mean(eta_squared_before, 'omitnan');
    stats.eta_squared_after = mean(eta_squared_after, 'omitnan');
    
    % Plot each feature's p-value
    figure('Visible','off');
    subplot(2, 1, 1);
    plot(p_before, 'o-', 'LineWidth', 1.5, 'Color', 'b');
    hold on;
    yline(0.01, '--r', 'LineWidth', 1.5);
    hold off;
    title('P-values (Before)');
    xlabel('Feature Index');
    ylabel('P-value');
    set(gca, 'FontSize',14);
    set(gca, 'YScale', 'linear'); % Use linear scale for y-axis
    set(gca, 'YTickLabel', arrayfun(@(x) sprintf('%.2f', x), get(gca, 'YTick'), 'UniformOutput', false)); % Format y-axis labels
    

    subplot(2, 1, 2);
    plot(p_after, 'o-', 'LineWidth', 1.5, 'Color', 'g');
    hold on;
    yline(0.01, '--r', 'LineWidth', 1.5);
    hold off;
    title('P-values (After)');
    xlabel('Feature Index');
    ylabel('P-value');
    set(gca, 'FontSize', 14);
    set(gca, 'YScale', 'linear'); % Use linear scale for y-axis
    set(gca, 'YTickLabel', arrayfun(@(x) sprintf('%.2f', x), get(gca, 'YTick'), 'UniformOutput', false)); % Format y-axis labels
    

    % Save the figure to the specified path
    saveas(gcf, fullfile(savepath, 'p_values_plot.png'));
    close(gcf); % Close the figure window
end

function result = conditional(condition, true_value, false_value)
    if condition
        result = true_value;
    else
        result = false_value;
    end
end
