%% Plot the normalized dF/F for one session of photometry data
% To run more than one session at once, please use batch version
%
% Input example: 
%    curr_path = 'C:'
%    sess = 'session_name'; % session name should end with three digit animal number
%    plot_raw = 0;  % plot raw trace (1 = yes, 0 = no)
%    plot_figs = 1; % plot figures (1 = yes, 0 = no)
%    save_figs = 0; % save figures in curr_path (1 = yes, 0 = no)
%    min_t = 0;     % minimum time in seconds to consider when plotting
%    max_t = 2400;  % maximum time in seconds to consider when plotting
%
% MAT-files required: none
%
% Author: Sandra Maesta-Pereira
% December 2019; Last revision: 08-October-2020
%------------- BEGIN CODE --------------

if not(exist('plot_raw', 'var'))
    % Write below if you want the raw data plotted (0 = no, 1 = yes):
    plot_raw = 0;
    plot_figs = 1;
    save_figs = 0;
end
if not(exist('plot_dt', 'var'))
    % Write below if you want the date and time plotted (0 = no, 1 = yes):
    plot_dt = 0;
end
if  not(exist('axis_label', 'var'))
    % Write below if you want the axis label plotted (0 = no, 1 = yes):
    axis_label = 0;
end
if not(exist('curr_path', 'var'))
    % Write below the path of the file you want ploted:
    curr_path = 'C:';
    cd(curr_path)
end


if  not(exist('sess', 'var'))
    % Write below the name of the session you want ploted (sess):
    sess = 'session';
end
if  not(exist('exp', 'var'))
    % Write below the name of the name of the experiment you want ploted (sess):
    exp = 'Torpor';
end
if  not(exist('max_t', 'var')) | not(exist('min_t', 'var'))
    % Write below the amount of seconds you want ploted:
    min_t = 0;
    max_t = 2400;
end

if  not(exist('min_dFF', 'var')) | not(exist('max_dFF', 'var'))
    % Write below the amount of seconds you want ploted:
    min_dFF = -20;
    max_dFF = 20;
end

% Use regex to get information
[match,noMatch] = regexp(sess,'((\d\d\d\d_b(?=\_))|(\d\d\d\d))','match','split');
animal = match(1, 1);
noMatch = char(noMatch(1, 2));
% Session letter
n_sess = regexp(noMatch,'(((?<=\_)[a-i]\d$)|((?<=\_)[a-i]$))','match');
n_sess = char(n_sess{1});
% Experiment name
exp_ = regexp(noMatch,'(?<=\_)[a-z]*(?=_)','match');

% Create title string
% if (not(exist('figure_name', 'var')) | strcmp(figure_name, 'default'))
% Write below if you want the raw data plotted (0 = no, 1 = yes):
title_s = char(strcat('Mouse #', animal, {' - '}, exp, {' session: '}, n_sess));
% else
%     title_s = figure_name;
% end

load(strcat(sess,'_000.mat'));
x = load(strcat(sess,'_000_logAI.csv'));


%  figure
sig(end) = sig(end-1);
ref(end) = ref(end-1);

m = mean(sig)/mean(ref);
disp(['m = ' num2str(m)]);
disp(['mean ref = ' num2str(mean(ref))]);


p = polyfit(ref,sig,1);
s = sig - (ref*p(1)+p(2));
s = s + mean(sig);
s = 100*(s-mean(s))/(mean(s));

time = 0:0.1:500 + 0.1*length(ref);
time = time(1:length(ref));


xtime = 0:0.005:time(end) + 10;
xtime = xtime(1:length(x(:,3)));
log = zeros(length(time),9);
for k = 1:9
    log(:,k) = interp1(xtime,x(:,k),time);
end

% Create variables for time and date of session file creation
d = dir(strcat(sess, '_000.mat'));
% Create variables for time and date of session file creation
if plot_dt == 1
    [hour, date] = regexp(d.date, '\d\d:\d\d:\d\d$', 'match', 'split');
    hour = hour{1, 1};
    date = date{1, 1};
    hour_double = str2double(regexp(hour,':','split'));
    % NOTE: time is adjusted to be 59 minutes ahead of the file time.
    pass_over = min(floor((hour_double(1, 2) + 1)/60), 1);
    hour_double(1, 1) = hour_double(1, 1) - 1 + pass_over;
    hour_double(1, 2) = hour_double(1, 2) + 1 - pass_over*60;
    
    dim = [.71 .88 .1 .1];
    a = annotation('textbox', dim, 'String', strcat(date, {' '}, num2str(hour_double(1, 1)), {':'}, num2str(hour_double(1, 2))), 'EdgeColor', 'none');
    a.FontSize = 9;
end

% Parametrize indexes according to time
min_t = (time(end)/2);
min_ind = min_t*10 + 1;
max_ind = min((max_t*10 + 1), size(s, 1));

adj_time = time(:, min_ind:max_ind);
adj_s = s(min_ind:max_ind, :);

% Session duration (chunk plotted and analized)
sess_dur = floor(size(adj_s, 1)/10);

if plot_raw == 1
    subplot(2,1,1)
    plot(ref)
    sig1 = sig/m;
    sig1 = sig1-mean(sig1);
    ref1 = 1*(ref-mean(ref));
    plot(adj_time,ref1(min_ind:max_ind, :),'c'), hold on
    
    axis tight
    
    plot(adj_time,sig1(min_ind:max_ind, :)*0.5,'r')
    % Set axis labels and limits
    ylabel('raw signals')
    ylim([-3000 3000])
    xlabel('time (seconds)')
    xlim([min_t max_t])
    
    % legend('ref','sig')
    
    subplot(2,1,2)
end

% FIGURE ONE
% figure with peak indications
if(plot_figs==1)
    fig1 = figure('Name', (char(strcat(title_s, {' with peaks'}))), 'NumberTitle', 'off', ...
        'FileName', (char(strcat(sess, {'_peaks'}))), 'Color', 'w');
    % plot(adj_time, adj_s, 'r');
    axis tight
    % Set axis labels and limits
    ylabel('dF/F (100%)')
    ylim([min_dFF max_dFF])
    xlabel('time (seconds)')
    xlim([min_t max_t])
    title(char(strcat(title_s, {' with peaks'})))
end
% Count number of peaks
[pks_75, ind_05] = findpeaks(adj_s, adj_time, 'MinPeakProminence', 7, 'MinPeakDistance', 5);
[pks_85, ind_5] = findpeaks(adj_s, adj_time, 'MinPeakProminence', 8, 'MinPeakDistance', 5);
if (strcmp(animal(1),'2954_b'))
    [pks_810, ind_810, w_810, p_810]= findpeaks(adj_s, adj_time, 'MinPeakProminence', 3, 'MinPeakDistance', 5);%,'WidthReference','halfheight')
else
    [pks_810, ind_810, w_810, p_810] = findpeaks(adj_s, adj_time, 'MinPeakProminence', 8, 'MinPeakDistance', 10);
end
[pks_825, ind_25] = findpeaks(adj_s, adj_time, 'MinPeakProminence', 8, 'MinPeakDistance', 25);
[pks_850, ind_50] = findpeaks(adj_s, adj_time, 'MinPeakProminence', 8, 'MinPeakDistance', 50);
%
%
if (plot_figs==1)
    if (strcmp(animal(1),'2954_b'))
        findpeaks(adj_s, adj_time, 'MinPeakProminence', 3, 'MinPeakDistance', 5, 'Annotate','extents')%,'WidthReference','halfheight')
    else
        findpeaks(adj_s, adj_time, 'MinPeakProminence', 8, 'MinPeakDistance', 10, 'Annotate','extents')%,'WidthReference','halfheight')
    end
end


% Calculate baseline
ind_three_min = floor(adj_time(end)/(60*3));
t_is = linspace(1, size(adj_s, 1)-1, ind_three_min);
baselines = zeros(1, ind_three_min-1);
for t_i = 1:ind_three_min-1
    baselines(1, t_i) = prctile(adj_s(t_is(t_i):t_is(t_i+1)), 10);
end
% baseline
activity_base = nanmean(baselines);
% Calculate baseline ONE MIN WINDOW
ind_one_min = floor(adj_time(end)/(60));
t_is = linspace(1, size(adj_s, 1)-1, ind_one_min);
baselines = zeros(1, ind_one_min-1);
for t_i = 1:ind_one_min-1
    baselines(1, t_i) = prctile(adj_s(t_is(t_i):t_is(t_i+1)), 10);
end
activity_base_onemin = nanmean(baselines);

% FIGURE TWO
% Second figure with no peak indications, with baseline
if (plot_figs==1)
    fig2 = figure('Name', title_s, 'NumberTitle', 'off', 'FileName', (char(strcat(sess, {'_baseline'}))), 'Color', 'w');
    title(char(strcat(title_s, {' with baseline'})));
    plot(adj_time, adj_s,'Color', [0, 0, 0]);
    hold on;
    plot([adj_time(1), adj_time(end)], [activity_base_onemin, activity_base_onemin], 'Color', [0.5, 0.5, 0.5]);
end
% amplitude of activity
activity_ampl = max(adj_s) - min(adj_s);
% amplitude of activity
activity_ampl_zsc = max(zscore(adj_s)) - min(zscore(adj_s));
% mean peak width
peak_wid = nanmean(w_810);
% mean peak proeminence
peak_pro = nanmean(p_810);
% mean peak height with respect to baseline
peak_hei_baseline = nanmean(abs(pks_810-activity_base));
% mean peak height with respect to zero
peak_hei_zero = nanmean(abs(pks_810));
% peak frequency in hertz
peak_fre = 60*size(pks_810, 1)/adj_time(end);

if (save_figs == 1)
    cd(curr_path)
    saveas(fig1, strcat(fig1.FileName, '.png'));
    saveas(fig2, strcat(fig2.FileName, '.png'));
end
