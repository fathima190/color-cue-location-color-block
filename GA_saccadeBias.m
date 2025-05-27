
clear; clc; close all;

pp2do         = [1:8, 10:16, 18:27];
nsmooth       = 200;
plotSinglePps = 0;
plotGAs       = 1;
plotFigures   = 1;
xlimtoplot    = [-100 1500];

% Colors for plotting
color_cue_colblock = [227,145,242]/255;
color_cue_locblock = [148, 179, 247]/255;

s = 0;
for pp = 1:25
    s = s + 1;
    param = getSubjParam(pp);
    disp(['Loading: ', param.subjName]);

    fname = [param.path, 'eyetrackingdata/saccadedata/saccadebias__1D__', param.subjName];
    load(fname, 'saccade', 'saccadesize');

    if nsmooth > 0
        saccade.toward = smoothdata(saccade.toward, 2, 'gaussian', nsmooth);
        saccade.away   = smoothdata(saccade.away, 2, 'gaussian', nsmooth);
        saccade.effect = smoothdata(saccade.effect, 2, 'gaussian', nsmooth);
        saccadesize.toward = smoothdata(saccadesize.toward, 3, 'gaussian', nsmooth);
        saccadesize.away   = smoothdata(saccadesize.away, 3, 'gaussian', nsmooth);
        saccadesize.effect = smoothdata(saccadesize.effect, 3, 'gaussian', nsmooth);
    end

    d1(s,:,:)     = saccade.toward;
    d2(s,:,:)     = saccade.away;
    d3(s,:,:)     = saccade.effect;
    d4(s,:,:,:)   = saccadesize.toward;
    d5(s,:,:,:)   = saccadesize.away;
    d6(s,:,:,:)   = saccadesize.effect;
end

% =================== CONDITION-SPECIFIC DATA ========================
bias_colblock     = squeeze(d3(:,4,:));
bias_locblock     = squeeze(d3(:,6,:));
toward_colblock   = squeeze(d1(:,4,:));
away_colblock     = squeeze(d2(:,4,:));
toward_locblock   = squeeze(d1(:,6,:));
away_locblock     = squeeze(d2(:,6,:));
sz_effect_col     = squeeze(mean(d6(:,4,:,:),3));
sz_effect_loc     = squeeze(mean(d6(:,6,:,:),3));

% Time-frequency structure for fieldtrip plotting
saccadesize.toward = squeeze(mean(d4));
saccadesize.away   = squeeze(mean(d5));
saccadesize.effect = squeeze(mean(d6));


if plotSinglePps
    figure;
    for sp = 1:s
        subplot(5,6,sp); hold on;
        plot(saccade.time, squeeze(d3(sp,4,:)), 'Color', color_cue_colblock);
        plot(saccade.time, squeeze(d3(sp,6,:)), 'Color', color_cue_locblock);
        xlim(xlimtoplot); ylim([-0.3 0.3]);
        title(['PP ', num2str(pp2do(sp))]);
        plot(xlim, [0 0], '--k');
    end
    legend({'Color Block','Location Block'});
end

if plotGAs
    figure;
    conds = [4 6];
    for idx = 1:length(conds)
        cond = conds(idx);
        subplot(1,2,idx); hold on;

        if cond == 4
            col = color_cue_colblock;
            lbl = 'Color Block';
            toward = toward_colblock;
            away = away_colblock;
        else
            col = color_cue_locblock;
            lbl = 'Location Block';
            toward = toward_locblock;
            away = away_locblock;
        end

        p1 = frevede_errorbarplot(saccade.time, toward, col, 'se');
        p2 = frevede_errorbarplot(saccade.time, away, [0.5 0.5 0.5], 'se');
        legend([p1, p2], {'Toward', 'Away'});
        title(lbl);
        xlim(xlimtoplot); ylim([0 1]);
        plot(xlim, [0 0], '--k');
    end
end

if plotFigures
    figure; hold on;
    p1 = frevede_errorbarplot(saccade.time, bias_colblock, color_cue_colblock, 'se');
    p2 = frevede_errorbarplot(saccade.time, bias_locblock, color_cue_locblock, 'se');
    plot(xlim, [0,0], '--k');
    plot([0,0], [-0.3 0.3], '--k');
    xlim(xlimtoplot); ylim([-0.3 0.3]);
    legend([p1, p2], {'Color Block', 'Location Block'});
    ylabel('Toward - Away (Hz)');
    xlabel('Time from Cue Onset (ms)');
    title('Microsaccade Bias – Color Cue Conditions');
end

figure;
cfg = [];
cfg.parameter = 'effect';
cfg.figure = 'gcf';
cfg.zlim = [-0.1, 0.1];
cfg.xlim = xlimtoplot;
cfg.colormap = 'jet';

conds = [4, 6];
for idx = 1:length(conds)
    cfg.channel = conds(idx);
    subplot(1,2,idx);
    ft_singleplotTFR(cfg, saccadesize);
    if cfg.channel == 4
        title('Saccade Size vs Time – Color Block');
    else
        title('Saccade Size vs Time – Location Block');
    end
    xlabel('Time (ms)'); ylabel('Saccade size (dva)');
    hold on
    plot([0,0], [0 7], '--k'); ylim([0.2 6.8]);
end

%% === ADDITIONAL ANALYSIS PLOTS ===

% Extract data
bias_colblock = squeeze(d3(:,4,:)); % Color Cue – Color Block
bias_locblock = squeeze(d3(:,6,:)); % Color Cue – Location Block
timevec = saccade.time;
xlimtoplot = [-100 1500]; % match your Code B settings

% Define color scheme
color_cue_colblock = [227,145,242]/255;  % light purple
color_cue_locblock = [148,179,247]/255;  % light blue
color_diff = [160, 70, 180]/255;         % dark purple for difference line

%% 1. PARTICIPANT TIMECOURSES (overlayed)
figure; hold on;
for sp = 1:size(d3,1)
    plot(timevec, bias_colblock(sp,:), 'Color', [color_cue_colblock, 0.25]);
    plot(timevec, bias_locblock(sp,:), 'Color', [color_cue_locblock, 0.25]);
end
plot(timevec, mean(bias_colblock), 'Color', color_cue_colblock, 'LineWidth', 2);
plot(timevec, mean(bias_locblock), 'Color', color_cue_locblock, 'LineWidth', 2);
plot([0 0], ylim, '--k');
xlim(xlimtoplot);
title('Participant Timecourses – Color vs Location Block');
legend({'Color Block (avg)', 'Location Block (avg)'}, 'Location', 'Best');
xlabel('Time (ms)'); ylabel('Effect (Hz)');
set(gca, 'FontSize', 12); box on;

%% 2. BAR PLOT OF MEAN EFFECT SIZE (with error bars)
% Select time window after cue (e.g. 950–1450 ms)
timewindow = timevec >= 950 & timevec <= 1450;
mean_col = mean(bias_colblock(:,timewindow), 2); % per participant
mean_loc = mean(bias_locblock(:,timewindow), 2);

figure;
bar_data = [mean(mean_col), mean(mean_loc)];
bar_err = [std(mean_col)/sqrt(length(mean_col)), std(mean_loc)/sqrt(length(mean_loc))];
bar(1, bar_data(1), 'FaceColor', color_cue_colblock); hold on;
bar(2, bar_data(2), 'FaceColor', color_cue_locblock);
errorbar(1:2, bar_data, bar_err, 'k.', 'LineWidth', 1.2);
xticks([1 2]); xticklabels({'Color Block', 'Location Block'});
ylabel('Mean Bias (Hz)');
title('Average Gaze Bias – Effect Size');
set(gca, 'FontSize', 12); box on;

%% 6.%% Refined Figure 6: Cleaner Difference Curve

% Settings
cue_onset = 0;
highlight_window = [300 800]; % time window for expected attention shift

% Data
diff_curve = bias_colblock - bias_locblock;
mean_diff = mean(diff_curve, 1);
sem_diff = std(diff_curve) ./ sqrt(size(diff_curve, 1));

% Colors
color_fill = [227, 145, 242]/255;        % light pink fill
color_line = [160, 70, 180]/255;         % stronger purple for line

figure; hold on;

% Highlight expected time window
yL = [-0.15 0.2];
fill([highlight_window fliplr(highlight_window)], [yL(1) yL(1) yL(2) yL(2)], ...
     [0.95 0.95 0.95], 'EdgeColor', 'none', 'FaceAlpha', 0.5);

% Shaded SEM area
fill([timevec fliplr(timevec)], ...
     [mean_diff + sem_diff, fliplr(mean_diff - sem_diff)], ...
     color_fill, 'EdgeColor', 'none', 'FaceAlpha', 0.4);

% Main difference line
plot(timevec, mean_diff, 'Color', color_line, 'LineWidth', 2.5);

% Reference lines
plot([cue_onset cue_onset], yL, '--k', 'LineWidth', 1); % cue onset
plot(xlim, [0 0], ':k');                               % zero baseline

% Labels and formatting
text(20, yL(2) - 0.02, 'Cue Onset', 'FontSize', 10, 'Color', 'k');
xlim([-100 1500]); ylim(yL);
xlabel('Time (ms)');
ylabel('Effect Difference (Hz)');
title('Difference in Bias: Color Block – Location Block');
set(gca, 'FontSize', 12); box on;
