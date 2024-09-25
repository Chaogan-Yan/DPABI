function FileSiteDistribution(SiteID, savepath)
    % Count unique elements
    [uniqueElements, ~, indices] = unique(SiteID);
    counts = histcounts(indices,1:(numel(uniqueElements) + 1));
    
    % Create figure
    fig= figure('Visible', 'off');
    b = bar(counts, 'FaceColor', '#007FFF', 'EdgeColor', 'w');

    % Add count labels
    xtips = b.XEndPoints;
    ytips = b.YEndPoints + 0.05;
    labels = string(counts);
    text(xtips, ytips, labels, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 12, ...
        'FontWeight', 'bold');

    % Set x-axis ticks and labels
    set(gca, 'XTick', 1:numel(uniqueElements), 'XTickLabel', uniqueElements);
    xtickangle(75);

    % Configure axes
    grid on;
    set(gca, ...
        'Box', 'off', ...
        'XGrid', 'off', ...
        'LineWidth', 1.5, ...
        'YMinorTick', 'off', ...
        'FontSize', 16);

    % Set labels and title
    xlabel('Site ID');
    ylabel('Sample Size');
    title('Sample Size per Site', 'FontSize', 20, 'FontWeight', 'bold');

    % Save figure
    saveas(fig, fullfile(savepath, 'site_distribution.png'));
    close(fig);
end