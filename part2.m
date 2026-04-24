rng = 12345;

% Same parameters as the model
timestamps = [10, 15, 20, 25];
beta0 = [0, 0, 0, 0]; 
beta1 = [0.0015, 0.0010, 0.0007, 0.0005]; 
num_games = 10000;

figure;
for i = 1:length(timestamps)
    % Standard deviation increases approx 1600 gold every time increase
    gold = randn(num_games, 1) * (1600 * i);
    
    z = beta0(i) + beta1(i) .* gold;
    p_true = 1 ./ (1 + exp(-z));
    
    % Simulate the win using weighted coin toss
    simulated_wins = double(rand(num_games, 1) < p_true);
    
    subplot(2, 2, i);
    hold on;
    
    % Bin the data
    edges = -10000:500:10000; % Changed step size to 500
    bin_centers = edges(1:end-1) + 250; % Center offset is now half of 500
    groups = discretize(gold, edges);
    valid = ~isnan(groups);
    exp_prob = accumarray(groups(valid), simulated_wins(valid), [length(bin_centers), 1], @mean, NaN);


    % Statistical Tests
    fprintf('\n Tests for t = %d mins\n', timestamps(i));

    % 1. Parameter Recovery
    mdl = fitglm(gold, simulated_wins, 'Distribution', 'binomial');
    ci = coefCI(mdl); 
    
    beta0_est = mdl.Coefficients.Estimate(1);
    beta1_est = mdl.Coefficients.Estimate(2);
    
    beta0_pass = (beta0(i) >= ci(1,1)) && (beta0(i) <= ci(1,2));
    beta1_pass = (beta1(i) >= ci(2,1)) && (beta1(i) <= ci(2,2));
    
    % Print Parameter Recovery Results
    fprintf('Parameter Recovery:\n');
    fprintf('Beta0: True = %.4f | Est = %.4f | 95%% CI: [%.4f, %.4f] | Pass: %s\n', beta0(i), beta0_est, ci(1,1), ci(1,2), mat2str(beta0_pass));
    fprintf('Beta1: True = %.6f | Est = %.6f | 95%% CI: [%.6f, %.6f] | Pass: %s\n', beta1(i), beta1_est, ci(2,1), ci(2,2), mat2str(beta1_pass));

    % 2. Chi-Square test
    
    obs_wins = accumarray(groups(valid), simulated_wins(valid));
    exp_wins = accumarray(groups(valid), p_true(valid));
    
    chi2_stat = sum(((obs_wins - exp_wins).^2) ./ (exp_wins + 1e-6));
    df = length(obs_wins) - 2;
    
    % Calculate the p-value
    p_value = 1 - chi2cdf(chi2_stat, df);
    
    % Print Goodness-of-Fit Results
    fprintf('Chi-Square Test:\n');
    fprintf('Statistic: %.2f | Degrees of Freedom: %d\n', chi2_stat, df);
    
    % Check against standard 0.05 alpha level
    if p_value > 0.05
        fprintf('p-value: %.4f PASS\n', p_value);
    else
        fprintf('p-value: %.4f FAIL\n', p_value);
    end
    fprintf('--------------------------------------\n');

    % Plot the binned dots
    plot(bin_centers, exp_prob, 'bo-', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
    
    % Plot model line
    g_smooth = linspace(min(gold), max(gold), 100);
    p_smooth = 1 ./ (1 + exp(-(beta0(i) + beta1(i) .* g_smooth)));
    plot(g_smooth, p_smooth, 'r-', 'LineWidth', 2);
    
    title(sprintf('t = %d mins', timestamps(i)));
    xlabel('Gold Difference');
    ylabel('Win Probability');
    ylim([-0.1 1.1]);
    xlim([-8000 8000]);
    grid on;
    
    if i == 1
        legend('Experimental Win % (Binned)', 'True Model Curve', 'Location', 'best');
    end
end

