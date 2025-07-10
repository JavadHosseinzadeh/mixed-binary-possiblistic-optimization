set(0,'DefaultAxesFontName', 'Times New Roman','DefaultAxesFontWeight','bold')
set(0,'DefaultAxesFontSize', 13,'DefaultLineLineWidth', 1.2);
% %% Discharging
% figure('Name','Discharging','Units','normalized','Position',[0 0 1 1]);
% dch_plot = stairs(1:size(value(dch),1),sum(D_matrix),'Color','k','LineWidth',2);
% hold on 
% dch_plot = stairs(1:size(value(dch),1),value(e__st),'Color','r','LineWidth',2);
% hold on 
% dch_plot = stairs(1:size(value(dch),1),value(dch - ch),'Color','y','LineWidth',2);
% hold on 
% dch_plot = stairs(1:size(value(dch),1),sum(value(gen)),'Color','b','LineWidth',2);
% hold on 
% dch_plot = stairs(1:size(value(dch),1),sum(value(ld)),'LineStyle',':','Color','g','LineWidth',2);
% hold on 
% dch_plot = stairs(1:size(value(dch),1),value(gen_csp),'Color','c','LineWidth',2);
% hold on 
% dch_plot = stairs(1:size(value(dch),1),value(H_csp),'Color','magenta','LineWidth',2);
% 
% % xlim([0.8 1.2]);
% % ylim([-20000 20000]);
% dch_plot.Color = '#D95319';
% dch_plot.MarkerSize = 20;
% dch_plot.LineWidth = 2;
% grid on;
% legend('Demand','Storage','Discharge-Charge','Generation','Load','gen csp','Heat csp')
% xlabel('sampling time')
% ylabel('Mega Watt')
% 
% %% Switches
% figure('Name','Switches','Units','normalized','Position',[0 0 1 1]);
% u_plot = stairs(1:size(value(u),1),value(u));
% % xlim([0.8 1.2]);
% % ylim([-20000 20000]);
% u_plot.Color = [0 0.4470 0.9910];
% u_plot.MarkerSize = 20;
% u_plot.LineWidth = 2;
% grid on;
% hold on;
% v_plot = stairs(1:size(value(v),1),value(v));
% v_plot.Color = '#D95319';
% v_plot.MarkerSize = 20;
% v_plot.LineWidth = 2;
% legend('charging switch','discharging switch');
% xlabel('sampling time')
% ylabel('Switch Modes Trajectory')
% 
% %%
% figure('Name','Power System Graph','Units','normalized','Position',[0 0 1 1]);
% G = digraph(mpc.branch(:,1),mpc.branch(:,2));
% p = plot(G,'Layout','force','UseGravity',true);
% %%
% Storage_Yearly_Investment = Storage_Investment * Inflation_rate_Year_TES;
% figure('Name','Investment Cost','Units','normalized','Position',[0 0 1 1]);
% Y_Invest = bar(Storage_Yearly_Investment,'FaceColor','flat');
% Y_Invest.CData(1,:) = [0.9 0 0];
% grid on;
% legend('Storage Investment in first year');
% xlabel('Year')
% ylabel('Investment Cost ($)')
%%
disp(['Optimal Size Of Storage = ', num2str(value(k__in))])
disp(['Optimal Size Of Csp = ', num2str(value(k__in/Min_discharge_period))])
disp(['Objective Function: = ', num2str(-value(Objective))])