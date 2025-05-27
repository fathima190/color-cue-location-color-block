
%% Step2b--grand average plots of gaze-position results

%% start clean
clear; clc; close all;

%% parameters
pp2do = [1:25];

nsmooth         = 200;
baselineCorrect = 1;
removeTrials    = 0; % remove trials with more than XX pixel deviation from baseline
plotSinglePps   = 1;
plotGAs         = 1;
xlimtoplot      = [-100 1500];

%% set visual parameters
[bar_size, colours, dark_colours, labels, subplot_size, percentageok] = setBehaviourParam(pp2do);

%% load and aggregate the data from all pp
s = 0;
for pp = pp2do;
    s = s+1;

    % get participant data
    param = getSubjParam(pp);

    % load
    disp(['getting data from participant ', param.subjName]);

    if baselineCorrect == 1 toadd1 = '_baselineCorrect'; else toadd1 = ''; end % depending on this option, append to name of saved file.
    if removeTrials == 1    toadd2 = '_removeTrials';    else toadd2 = ''; end % depending on this option, append to name of saved file.
    filename = ['gazePositionEffects__', toadd1(2:end), toadd2, '__', param.subjName, '.mat'];
    filepath = fullfile(param.path, 'eyetrackingdata/gazePositionBias', filename);
    
    disp(['Looking for file: ', filepath]); % optional, for debugging
    
    if isfile(filepath)
        load(filepath, 'gaze');
    else
        warning('File not found: %s', filepath);
        continue;
    end
    dir(fullfile(param.path, 'eyetrackingdata/gazePositionBias', 'gazePositionEffects__*'))



    % smooth?
    if nsmooth > 0
    for x1 = 1:size(gaze.dataL,1)
        gaze.dataL(x1,:)      = smoothdata(gaze.dataL(x1,:), 'gaussian', nsmooth);
        gaze.dataR(x1,:)      = smoothdata(gaze.dataR(x1,:), 'gaussian', nsmooth);
        gaze.towardness(x1,:) = smoothdata(gaze.towardness(x1,:), 'gaussian', nsmooth);
        gaze.blinkrate(x1,:)  = smoothdata(gaze.blinkrate(x1,:), 'gaussian', nsmooth);
    end
    end


    % put into matrix, with pp as first dimension
    d1(s,:,:) = gaze.dataR;
    d2(s,:,:) = gaze.dataL;
    d3(s,:,:) = gaze.towardness;
    d4(s,:,:) = gaze.blinkrate;
    
    end

%% make GA

%% all subs
if plotSinglePps
    % towardness
    figure;
    for sp = 1:s
        subplot(subplot_size, subplot_size, sp); hold on;
        plot(gaze.time, squeeze(d3(sp,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-5 5]);
        title(pp2do(sp));
    end

    % blink rate
    figure;
    for sp = 1:s
        subplot(subplot_size, subplot_size, sp); hold on;
        plot(gaze.time, squeeze(d4(sp,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-20 100]);
        title(pp2do(sp));
    end
    legend(gaze.label);
end

%% plot grand average data patterns of interest, with error bars
if plotGAs
    % right and left cues, per condition
    figure('Position', [100, 100, 1000, 400]);  % Wide layout for side-by-side plots
    
    % Define colors
    colorR = [213, 137, 232] / 255;  % custom purple for 'R'
    colorL = [0, 0, 1];              % blue for 'L'
    
    % Plot for condition 4 - Color Block
    subplot(1, 2, 1); hold on;
    title('Color Cue - Color Block');
    p1 = frevede_errorbarplot(gaze.time, squeeze(d1(:,4,:)), colorR, 'se');
    p2 = frevede_errorbarplot(gaze.time, squeeze(d2(:,4,:)), colorL, 'se');
    xlabel('Time (ms)');
    ylabel('Horizontal Gaze (px)');
    xlim(xlimtoplot);
    ylim([-3 3]);
    legend([p1, p2], {'R','L'});
    
    % Plot for condition 6 - Location Block
    subplot(1, 2, 2); hold on;
    title('Color Cue - Location Block');
    p1 = frevede_errorbarplot(gaze.time, squeeze(d1(:,6,:)), colorR, 'se');
    p2 = frevede_errorbarplot(gaze.time, squeeze(d2(:,6,:)), colorL, 'se');
    xlabel('Time (ms)');
    ylabel('Horizontal Gaze (px)');
    xlim(xlimtoplot);
    ylim([-3 3]);
    legend([p1, p2], {'R','L'});
    
    % towardness per condition!!!
    figure('Position', [100, 100, 600, 400]);  % Single merged plot
    hold on;
    
    % Plot for Color Block (sp = 4)
    frevede_errorbarplot(gaze.time, squeeze(d3(:,4,:)), [227,145,242]/255, 'both');
    
    % Plot for Location Block (sp = 6)
    frevede_errorbarplot(gaze.time, squeeze(d3(:,6,:)), [148,179,247]/255, 'both');
    
    % Horizontal reference
    plot([-2000 2000], [0 0], '--k');
    
    % Axis labels and title
    xlabel('Time (ms)');
    ylabel('Towardness (px)');
    title('Color Cue Conditions: Color vs. Location Block');
    
    % Set x-axis range (in ms)
    xlim([-2000 2000]);
    
    legend({'Color Block', 'Location Block'});


    
%% towardness overlay of all conditions
    figure; hold on;
    ylimit = [-4, 4];
    plot([0,0], [ylimit], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    frevede_errorbarplot(gaze.time, squeeze(d3(:,2,:)), [1,0,0], 'se');
    frevede_errorbarplot(gaze.time, squeeze(d3(:,4,:)), [0,0,1], 'se');

    ylim(ylimit);
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    legend(gaze.label(2:4));
    xlim(xlimtoplot);
    ylabel('Gaze towardness (px)');
    xlabel('Time (ms)');

    ylimit2 = [-4, 3];
    figure;

    % 1 2 4 6 itippo 2ila
    % subplot(1,2,1);
    hold on;
    p1 = frevede_errorbarplot(gaze.time, squeeze(d3(:,2,:)), 'k', 'both');
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylimit2, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    xlim(xlimtoplot);
    ylabel('Gaze towardness (px)');
    xlabel('Time (ms)');
    ylim(ylimit2);
    
    % subplot(1,2,2); hold on;
    % p1 = plot(gaze.time, squeeze(d3(:,5,:)));
    % plot(xlim, [0,0], '--k');
    % legend([p1], gaze.label(5));
    % xlim(xlimtoplot);
    % 
    %% blink rate
    figure; 
    hold on;
    frevede_errorbarplot(gaze.time, squeeze(d4(:,2,:)), [1,0,0], 'se');
    frevede_errorbarplot(gaze.time, squeeze(d4(:,4,:)), [0,0,1], 'se');
    plot(xlim, [0,0], '--k');
    plot([0,0], [-5, 30], '--k')
    xlim(xlimtoplot);

end

