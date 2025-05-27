%% Script for analyzing towardness data using cluster-based permutation
% Rewritten based on Prof's template - simplified and standardized

clear; clc; close all;

%% Load data
load('gaze_bias_towardness.mat', 'd3', 'time');  % d3: subj x cond x time

%% Configuration for statistics
statcfg.xax = time;
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = size(d3,1);
statcfg.statMethod = 'montecarlo';

%% Define data
data_cond1 = d3(:,4,:);  % Color Block
data_cond2 = d3(:,6,:);  % Location Block

null_data = zeros(size(data_cond1));

% Run stats
stat1 = frevede_ftclusterstat1D(statcfg, data_cond1, null_data);
stat2 = frevede_ftclusterstat1D(statcfg, data_cond2, null_data);
stat_comp = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2);

%% Plot
mask_xxx = double(stat_comp.mask);
mask_xxx(mask_xxx==0) = nan;

figure; hold on;
ylimit = [-2, 2];  % Set y-axis
xlim([0 1500]);    % Set x-axis

p1 = frevede_errorbarplot(time, squeeze(d3(:,4,:)), [227,145,242]/255, 'se'); % Color Block
p2 = frevede_errorbarplot(time, squeeze(d3(:,6,:)), [148,179,247]/255, 'se'); % Location Block
p1.LineWidth = 1.5;
p2.LineWidth = 1.5;

plot(xlim, [0,0], '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 2);  % Reference line
plot([0,0], ylimit, '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 2);  % Zero line

sig = plot(time, mask_xxx * -0.1, 'k', 'LineWidth', 4);  % Significance line
ylim(ylimit);

xlabel('Time (ms)');
ylabel('Towardness (px)');
title('Gaze Towardness Comparison: Color vs Location Block');

% Show only desired lines in the legend
legend([p1, p2], {'Color Block', 'Location Block'}, 'Location', 'Best');
signif_time_ms = [min(find(stat1.mask == 1)), max(find(stat1.mask == 1))];
disp(signif_time_ms);

