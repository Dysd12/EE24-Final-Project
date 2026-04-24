gold_range = linspace(-10000, 10000, 1000); 

% Choose values for B0 and B1
timestamps = [10, 15, 20, 25];
beta0_true = [0, 0, 0, 0]; 
beta1_true = [0.0015, 0.0010, 0.0007, 0.0005]; 
colors = {'b', 'm', 'g', 'r'}; 

figure('Name', 'Model Simuation Plots');
hold on; 

% Plot at each time
for i = 1:length(timestamps)
    b0 = beta0_true(i);
    b1 = beta1_true(i);
    z = b0 + b1 .* gold_range;
    p_win = 1 ./ (1 + exp(-z)); 
    
    plot(gold_range, p_win, 'LineWidth', 2.5, 'Color', colors{i},'DisplayName', sprintf('t = %d mins (beta_1 = %.4f)', timestamps(i), b1));
end

title('Theoretical Win Probability vs Gold Difference');
xlabel('Gold Difference');
ylabel('Win Probability');
ylim([0 1]);
xlim([-10000 10000]);
grid on;
legend('Location', 'southeast');

plot([0 0], [0 1], 'k--', 'HandleVisibility', 'off');
plot([-10000 10000], [0.5 0.5], 'k--', 'HandleVisibility', 'off');
