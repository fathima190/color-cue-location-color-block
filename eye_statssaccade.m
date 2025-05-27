%% Script for doing stats on saccade and gaze bias data.
% So run the preprocessing scripts (e.g., get_saccadeBias.m) first.
% by Anna, updated by ChatGPT, 02-04-2025

%% === Load saccade bias data from all participants ===
% clear; clc;
color_cue_colblock = [227,145,242]/255;
color_cue_locblock = [148, 179, 247]/255;
statcfg.clusterstatistic = 'maxsum';  % avoids SPM
statcfg.correctm = 'cluster';
statcfg.tail = 0;
statcfg.alpha = 0.05;
statcfg.statistic = 'depsamplesT';
statcfg.method = 'montecarlo';
statcfg.neighbours = []; % no neighbours in 1D

pp2do = 1:25;
s = 0;

for pp = pp2do
    s = s + 1;

    param = getSubjParam(pp);
    disp(['Loading data from participant ', param.subjName]);

    load([param.path, 'eyetrackingdata/saccadedata/saccadebias__1D__', param.subjName], 'saccade');

    d3(s,:,:) = saccade.effect; % aggregate towardness effect across participants

    if s == 1
        saccade_time = saccade.time;
        saccade_label = saccade.label;
    end
end

%% === Saccade bias data - stats ===
statcfg = [];
statcfg.xax = saccade.time;
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo';
% statcfg.statMethod = 'analytic';

timeframe = 951:1951; %0 - 1000 ms post-cue
data_cond1 = d3(:, 4, timeframe);
data_cond2 = d3(:, 6, timeframe);
null_data = zeros(size(data_cond1));

stat1 = frevede_ftclusterstat1D(statcfg, data_cond1, null_data);
stat2 = frevede_ftclusterstat1D(statcfg, data_cond2, null_data);
stat_comp = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2);

%% === Saccade bias data - plot only effect ===
mask_1 = double(stat1.mask);
mask_1(mask_1 == 0) = nan; % nan-out non-significant data

mask_2 = double(stat2.mask);
mask_2(mask_2 == 0) = nan;

mask_3 = double(stat_comp.mask);
mask_3(mask_3 == 0) = nan;

figure; hold on;
ylimit = [-0.3, 0.3];

p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:, 4, :)), color_cue_colblock, 'se');
p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:, 6, :)), color_cue_locblock, 'se');

p1.LineWidth = 1.5;
p2.LineWidth = 1.5;

plot(xlim, [0, 0], '--', 'LineWidth', 2, 'Color', [0.6, 0.6, 0.6]);
plot([0, 0], ylimit, '--', 'LineWidth', 2, 'Color', [0.6, 0.6, 0.6]);

xlim(xlimtoplot); % or whatever range you want;
sig1 = plot(saccade.time(timeframe), mask_1 * -0.11, 'Color', color_cue_colblock, 'LineWidth', 4); % significance line
sig2 = plot(saccade.time(timeframe), mask_2 * -0.13, 'Color', color_cue_locblock, 'LineWidth', 4); % significance line
sig_comp = plot(saccade.time(timeframe), mask_3 * -0.15, 'k', 'LineWidth', 4); % significance line

ylim([-0.2, 0.2]);

ylabel('Rate effect (delta Hz)');
xlabel('Time (ms)');

% set(gcf,'position',[0,0, 1800,900])
% fontsize(ft_size*1.5,"points")

legend([p1, p2], saccade.label([4,6]));
signif_time_ms = [min(find(stat1.mask == 1)), max(find(stat1.mask == 1))];
disp(signif_time_ms);


