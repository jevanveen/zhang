% BATCH RUN
% Plot the normalized dF/F for one or more sessions. Please fill the
% information below.

% clearvars

% Write below the name of the figure you want or just write 'default':
figure_name = 'Photometry_g_sessions_2nd_half';

% Write below if you want the raw data plotted (0 = no, 1 = yes):
plot_raw = 0;
plot_figs = 1;

% Write below if you want the time and date plotted (0 = no, 1 = yes):
plot_dt = 1;

% Write below if you want all sessions plotted in the same figure (0 = no, 1 = yes):
same_fig = 0;

% Write below the path of the location of the files you want ploted:
curr_path = 'C:\Users\Adhikari Lab\Desktop\Zhi';

% Write below the names of the sessions you want ploted (sessions):
% sessions = {'2953_temp_a', '2954_temp_b', '2955_temp_a', '2958_temp_a', '2954_temp_a'}; %'2953_temp_a', '2954_temp_b', '2955_temp_a', '2958_temp_a', 
    
% Write below the name of the name of the experiment you want ploted (sess):
exp = '2nd_half';

% Write below the time limits in seconds you want ploted:
max_t = 2400;
min_t = 60;
% Parametrize indexes according to time
min_ind = min_t*10 + 1;
max_ind = max_t*10 + 1;

% Write below the dF/F limits you want ploted:
min_dFF = -20;
max_dFF = 40;

save_figs = 1;



% Array to store all animal numbers
ani_num = repmat('', (size(sessions, 2)), 1);
% Array to store all session letters/numbers
sess_info = repmat('', (size(sessions, 2)), 1);
% Array to store experiment type
exp_all = repmat('', (size(sessions, 2)), 1);
% Array to store all dates and times
dt_adj = repmat('', (size(sessions, 2)), 1);
% Array to store all dates and times
sess_duration = zeros((size(sessions, 2)), 1);

% Array to store all means of adjusted signals
mean_adj = zeros((size(sessions, 2)), 1);
% Array to store all variances of adjusted signals
var_adj = zeros((size(sessions, 2)), 1);
% Array to store all standard deviations of adjusted signals
std_adj = zeros((size(sessions, 2)), 1);
% Array to store all areas under the curve of adjusted signals
auc_adj = zeros((size(sessions, 2)), 1);
% Array to store all areas under the curve (between minimum value and s) of adjusted signals
auc_adj_minval = zeros((size(sessions, 2)), 1);
% Array to store number of peaks in adjusted signals
pks_adj = zeros((size(sessions, 2)), 1);
% Array to store number of peaks in adjusted signals
mad_adj = zeros((size(sessions, 2)), 1);

% Array to store sum of areas of peaks in adjusted signals
sum_pks_area = zeros((size(sessions, 2)), 1);
% Array to store average area of peaks of adjusted signals
avg_pks_area = zeros((size(sessions, 2)), 1);

act_base = zeros((size(sessions, 2)), 1);
act_base_onemin = zeros((size(sessions, 2)), 1);
act_ampl = zeros((size(sessions, 2)), 1);
act_ampl_zsc = zeros((size(sessions, 2)), 1);
avg_pks_widt = zeros((size(sessions, 2)), 1);
avg_pks_proe = zeros((size(sessions, 2)), 1);
avg_pks_hei_base = zeros((size(sessions, 2)), 1);
avg_pks_hei_zero = zeros((size(sessions, 2)), 1);
avg_pks_freq = zeros((size(sessions, 2)), 1);

if same_fig == 0
    axis_label = 1;
    for i = 1:size(sessions, 2)
        cd(curr_path)
        cd(folders{i})
        sess = char(sessions(i));
             
        fp_torpor_080620;
        
        ani_num{i} = animal{1, 1};
        sess_info{i} = n_sess;
        if (hour_double(1, 2)<10)
            temp = strcat({'0'}, num2str(hour_double(1, 2)));
        else
            temp = num2str(hour_double(1, 2));
        end
        exp_all{i} = exp_{1, 1};
        dt_adj{i} = char(strcat(date, {' '}, num2str(hour_double(1, 1)), {':'}, temp));
        sess_duration(i, 1) = sess_dur;
        
        mean_adj(i, 1) = mean(adj_s);  
        var_adj(i, 1) = var(adj_s);
        std_adj(i, 1) = sqrt(var_adj(i, 1));
        auc_adj(i, 1) = abs(trapz(adj_time, adj_s));
        auc_adj_minval(i, 1) = trapz(adj_time, adj_s + (abs(min(adj_s))));
        pks_adj(i, 1) = size(pks_810, 1);
%         sum_pks_area(i, 1) = sum(pks_area);
%         avg_pks_area(i, 1) = mean(pks_area);
        
        act_base(i, 1) = activity_base;
        act_base_onemin(i, 1) = activity_base_onemin;
        act_ampl(i, 1) = activity_ampl;
        act_ampl_zsc(i, 1) = activity_ampl_zsc;
        avg_pks_widt(i, 1) = peak_wid;
        avg_pks_proe(i, 1) = peak_pro;
        avg_pks_hei_base(i, 1) = peak_hei_baseline;
        avg_pks_hei_zero(i, 1) = peak_hei_zero;
        avg_pks_freq(i, 1) = peak_fre;
        
    end
else
    axis_label = 1;
            
    fp_torpor_same_fig;
end

% Create table with all information
k = table(ani_num.', exp_all.', sess_info.', sess_duration, dt_adj.', var_adj, auc_adj_minval, pks_adj, ...
    act_base_onemin, act_ampl,  act_ampl_zsc, avg_pks_widt, avg_pks_proe, avg_pks_hei_base, avg_pks_hei_zero, avg_pks_freq);
k.Properties.VariableNames = {'Animal', 'Experiment', 'Session', 'Session_Duration', 'Date_Time', 'Variance', 'AUC_min_fl', 'Peak_count',...
    'Baseline_one_minute', 'Activity_amplitude', 'Activity_amplitude_zscore', 'Mean_peak_width', 'Mean_peak_proeminence',...
    'Mean_peak_distance_from_baseline','Mean_peak_distance_from_zero', 'Peak_frequency_Hz'};

% k = table(ani_num.', exp_all.', sess_info.', sess_duration, dt_adj.', var_adj, auc_adj_minval, pks_adj, ...
%     act_base, act_base_onemin, act_ampl,  act_ampl_zsc, avg_pks_widt, avg_pks_proe, avg_pks_hei_base, avg_pks_hei_zero, avg_pks_freq);
% k.Properties.VariableNames = {'Animal', 'Experiment', 'Session', 'Session_Duration', 'Date_Time', 'Variance', 'AUC_min_fl', 'Peak_count',...
%     'Baseline', 'Baseline_one_minute', 'Activity_amplitude', 'Activity_amplitude_zscore', 'Mean_peak_width', 'Mean_peak_proeminence',...
%     'Mean_peak_distance_from_baseline','Mean_peak_distance_from_zero', 'Peak_frequency_Hz'};

% k = table(ani_num.', sess_info.', dt_adj.', mean_adj, var_adj, std_adj, auc_adj_minval, peaks_adj);
% k.Properties.VariableNames = {'Animal', 'Session', 'Date_Time', 'Mean_dFF', 'Variance', 'Standard_Deviation', 'AUC_min_fl', 'Peak_count'};

% Export table to excel file
cd(curr_path)
filename = figure_name;
cd('figures_081020/g_sessions_2nd_half')
writetable(k, 'Photometry_g_sessions_2nd_half.xlsx', 'Sheet', 1, 'Range', 'A1', 'WriteVariableNames', true)
