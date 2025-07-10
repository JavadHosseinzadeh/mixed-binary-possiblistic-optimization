clc
clear all
close all
                                        load('sen39_nec_0.00.mat');
%%
gen = Res{1,1};
ld = Res{1,2};
ch = Res{1,3};
dch = Res{1,4};
e__st = Res{1,5};
k__in = Res{1,6};
u = Res{1,7};
v = Res{1,8};
Objective = Res{1,9};
D_matrix = Res{1,10};
mpc = Res{1,11};
T = 8760;
k__csp = Res{1,12};
H_csp = Res{1,13};
gen_csp = Res{1,14};
set(0,'DefaultAxesFontName', 'Times New Roman','DefaultAxesFontWeight','bold')
set(0,'DefaultAxesFontSize', 13,'DefaultLineLineWidth', 1.2);
%% Discharging
figure('Name','Discharging','Units','normalized','Position',[0 0 1 1]);
dch_plot = stairs(1:size(dch,1),sum(D_matrix),'Color','k','LineWidth',2);
hold on 
dch_plot = stairs(1:size(dch,1),e__st,'Color','r','LineWidth',2);
hold on 
dch_plot = stairs(1:size(dch,1),dch - ch,'Color','y','LineWidth',2);
hold on 
dch_plot = stairs(1:size(dch,1),sum(gen),'Color','b','LineWidth',2);
hold on 
dch_plot = stairs(1:size(dch,1),sum(ld),'LineStyle',':','Color','g','LineWidth',2);
hold on 
dch_plot = stairs(1:size(value(dch),1),gen_csp,'Color','c','LineWidth',2);
hold on 
dch_plot = stairs(1:size(value(dch),1),H_csp,'Color','magenta','LineWidth',2);
% xlim([0.8 1.2]);
% ylim([-20000 20000]);
dch_plot.Color = '#D95319';
dch_plot.MarkerSize = 20;
dch_plot.LineWidth = 2;
grid on;
legend('Demand','Storage','Discharge-Charge','Generation','Load','gen csp','heat_csp')
xlabel('sampling time')
ylabel('Mega Watt')
title(['Power Plot'] ,...
['Time: ',num2str(T), ' Hour ']);
%% Switches
figure('Name','Switches','Units','normalized','Position',[0 0 1 1]);
u_plot = stairs(1:size(u,1),u);
% xlim([0.8 1.2]);
% ylim([-20000 20000]);
u_plot.Color = [0 0.4470 0.9910];
u_plot.MarkerSize = 20;
u_plot.LineWidth = 2;
grid on;
hold on;
v_plot = stairs(1:size(v,1),v);
v_plot.Color = '#D95319';
v_plot.MarkerSize = 20;
v_plot.LineWidth = 2;
legend('charging switch','discharging switch');
xlabel('sampling time')
ylabel('Switch Modes Trajectory')
title('Swithces Plot' ,...
['Time: ',num2str(T), ' Hour ']);
%%
figure('Name','Power System Graph','Units','normalized','Position',[0 0 1 1]);
names = {'PQ',' ','PQ','PQ',' ',' ','PQ','PQ','PQ','CSP - TES',...
    ' ','PQ',' ',' ','PQ','PQ',' ','PQ',' ','PQ',...
    'PQ',' ','PQ','PQ','PQ','PQ','PQ','PQ','PQ','PV',...
    'Slack','PV','PV','PV','PV','PV','PV','PV','PV'}';

G = digraph(mpc.branch(:,1),mpc.branch(:,2));
p = plot(G,'NodeLabel',names,'Layout','force','UseGravity',true);
p.Marker = 'h';
p.NodeColor = 	'#EDB120';
p.LineWidth = 1.5;
p.MarkerSize= 6;
p.ArrowSize = 8;
p.DisplayName = 'GRAPH';
p.ArrowPosition = 0.5;
p.EdgeColor='c';
p.EdgeFontSize=10;
p.NodeFontSize=8;
highlight(p,find(mpc.bus(:,3)~=0),'Marker','o')
highlight(p,[30 32 33 34 35 36 37 38 39],'NodeColor',[1 0 0],'MarkerSize',8)
highlight(p,31,'NodeColor',	[0 0 0],'MarkerSize',8)
highlight(p,10,'NodeColor','#0072BD','MarkerSize',8)
%%
disp(['Optimal Size Of Storage = ', num2str(value(k__in))])
disp(['Optimal Size Of Csp = ', num2str(value(k__csp))])
disp(['Objective Function: = ', num2str(-value(Objective))])
%%
%% Discharging
%% Discharging
figure('Name','Discharging','Units','normalized','Position',[0 0 1 1]);

% Main plot for first 7 days (7*24 samples)
% subplot('Position', [0.1, 0.1, 0.65, 0.8]); % Main plot occupying most of the figure
hold on;

% Plotting the first 7*24 samples
stairs(1:7*24, sum(D_matrix(:,1:7*24)), 'Color', [0 0 0], 'LineWidth', 1.5); % Black for Demand
stairs(1:7*24, e__st(1:7*24), 'Color', [0.85, 0.33, 0.1], 'LineWidth', 1.5); % Orange for Storage
stairs(1:7*24, (dch(1:7*24) - ch(1:7*24)), 'Color', [0.93, 0.69, 0.13], 'LineWidth', 1.5); % Yellow for Discharge-Charge
stairs(1:7*24, sum(gen(:,1:7*24)), 'Color', [0 0.45 0.74], 'LineWidth', 1.5); % Blue for Generation
stairs(1:7*24, sum(ld(:,1:7*24)), 'LineStyle', ':', 'Color', [0.47, 0.67, 0.19], 'LineWidth', 1.5); % Green (dotted) for Load
stairs(1:7*24, gen_csp(1:7*24), 'Color', [0.30, 0.75, 0.93], 'LineWidth', 1.5); % Cyan for Gen CSP
stairs(1:7*24, H_csp(1:7*24), 'Color', [0.49, 0.18, 0.56], 'LineWidth', 1.5); % Magenta for Heat CSP

% Labels, title, legend for main plot
ylim([-300 7000])
xlabel('Sampling time (Hour)');
ylabel('Power (Mega Watt)');
title('Power Plot for First 7 Days');
grid minor;
legend('Demand','Storage','Discharge-Charge','Generation','Load','Gen CSP','Heat CSP', 'Location', 'best');


% Zoomed-in plot for full year data (8760 samples)
inset_axes = axes('Position', [0.17, 0.7, 0.6, 0.15]); % Inset plot in top part of the main plot
box on; % Box around the inset plot
hold on;

% Plotting all variables for the full year
stairs(1:size(dch,1), sum(D_matrix), 'Color', [0 0 0], 'LineWidth', 1.5); % Black for Demand
stairs(1:size(dch,1), e__st, 'Color', [0.85, 0.33, 0.1], 'LineWidth', 1.5); % Orange for Storage
stairs(1:size(dch,1), dch - ch, 'Color', [0.93, 0.69, 0.13], 'LineWidth', 1.5); % Yellow for Discharge-Charge
stairs(1:size(dch,1), sum(gen), 'Color', [0 0.45 0.74], 'LineWidth', 1.5); % Blue for Generation
stairs(1:size(dch,1), sum(ld), 'LineStyle', ':', 'Color', [0.47, 0.67, 0.19], 'LineWidth', 1.5); % Green (dotted) for Load
stairs(1:size(dch,1), gen_csp, 'Color', [0.30, 0.75, 0.93], 'LineWidth', 1.5); % Cyan for Gen CSP
stairs(1:size(dch,1), H_csp, 'Color', [0.49, 0.18, 0.56], 'LineWidth', 1.5); % Magenta for Heat CSP

% Labels, title for inset plot
xlabel('Sampling time (Hour)');
ylabel('Power (MW)');
title('Full Year Overview');
grid minor;

% Set the color of the last plotted line (if necessary)
dch_plot = stairs(1:size(dch,1), H_csp, 'Color', [0.49, 0.18, 0.56], 'LineWidth', 1.5);
dch_plot.Color = '#D95319';
dch_plot.MarkerSize = 20;
dch_plot.LineWidth = 2;

hold off;

