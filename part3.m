filename = 'league.csv';
opts = detectImportOptions(filename);
opts.VariableNamingRule = 'preserve';
data_table = readtable(filename, opts);

col_times = [112, 127, 142, 157]; % Columns for t=10, 15, 20, 25
timestamps = [10, 15, 20, 25];
col_win = 31;

max_rows = size(data_table, 1);
row_indices = 12:12:max_rows;
game_results = data_table{row_indices, col_win}; % The real wins and losses

figure;

discovered_beta0 = zeros(1, 4);
discovered_beta1 = zeros(1, 4);

for i = 1:length(timestamps)
    
    % Get the real gold differences for this specific timestamp
    real_gold = data_table{row_indices, col_times(i)};
    
    valid_data = ~isnan(real_gold) & ~isnan(game_results);
    clean_gold = real_gold(valid_data);
    clean_wins = game_results(valid_data);
    
    mdl = fitglm(clean_gold, clean_wins, 'Distribution', 'binomial', 'Link', 'logit');
    
    % Extract the discovered Beta values
    b0 = mdl.Coefficients.Estimate(1); % Beta 0
    b1 = mdl.Coefficients.Estimate(2); % Beta 1
    
    % Store them to print later
    discovered_beta0(i) = b0;
    discovered_beta1(i) = b1;
    
    subplot(2, 2, i);
    hold on;
    
    % Plot the Empirical Data (Binned Averages)
    bin_size = 500;
    edges = floor(min(clean_gold)/bin_size)*bin_size : bin_size : ceil(max(clean_gold)/bin_size)*bin_size;
    bin_centers = edges(1:end-1) + bin_size/2;
    groups = discretize(clean_gold, edges);
    valid_groups = ~isnan(groups);
    exp_prob = accumarray(groups(valid_groups), clean_wins(valid_groups), [length(bin_centers), 1], @mean, NaN);
    ax = gca; ax.XAxis.Exponent = 0; 

    % Draw the dots for the real data
    plot(bin_centers, exp_prob, 'ko', 'MarkerFaceColor', [0.7 0.7 0.7], 'MarkerSize', 6);
    
    % Plot the Theoretical Model
    g_smooth = linspace(min(clean_gold), max(clean_gold), 200);
    p_smooth = 1 ./ (1 + exp(-(b0 + b1 .* g_smooth)));
    
    colors = {'b', 'm', 'g', 'r'};
    plot(g_smooth, p_smooth, '-', 'Color', colors{i}, 'LineWidth', 2.5);
    
    % Formatting
    title(sprintf('t = %d mins', timestamps(i)));
    xlabel('Gold Difference');
    ylabel('Win Probability');
    ylim([-0.05 1.05]);
    grid on;
    
    % Adding the model equation on the graph
    eq_text = sprintf('P(Win) = 1 / (1 + e^{-(%.3f + %.5f*g)})', b0, b1);
    text(min(clean_gold)*0.8, 0.8, eq_text, 'FontSize', 9, 'BackgroundColor', 'w');
    
    if i == 1
        legend('Empirical Data (Bins)', 'Fitted Logistic Model', 'Location', 'southeast');
    end
    hold off;
end

% Print the final discovered values to the Command Window
fprintf('\nResults\n');
for i = 1:length(timestamps)
    fprintf('t = %d mins: B_0 (Bias) = %8.4f, B_1 (Gold Weight) = %8.6f\n', timestamps(i), discovered_beta0(i), discovered_beta1(i));
end


% Find the real standard deviation for each timestamp
real_std_10 = std(data_table{row_indices, col_times(1)}, 'omitnan');
real_std_15 = std(data_table{row_indices, col_times(2)}, 'omitnan');
real_std_20 = std(data_table{row_indices, col_times(3)}, 'omitnan');
real_std_25 = std(data_table{row_indices, col_times(4)}, 'omitnan');

fprintf('Real Standard Deviation at 10m: %.2f\n', real_std_10);
fprintf('Real Standard Deviation at 15m: %.2f\n', real_std_15);
fprintf('Real Standard Deviation at 20m: %.2f\n', real_std_20);
fprintf('Real Standard Deviation at 25m: %.2f\n', real_std_25);