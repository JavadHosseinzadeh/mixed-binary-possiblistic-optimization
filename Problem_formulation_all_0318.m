gen = sdpvar(numgen,timeline);
ld = sdpvar(numnode,timeline);
ch = sdpvar(timeline,1);
dch = sdpvar(timeline,1);  
e__st = sdpvar(timeline,1);
e__in = sdpvar(1,1);
k__in = sdpvar(1,1);
alpha = sdpvar(timeline,1);
beta = sdpvar(timeline,1);
u = binvar(timeline,1);
v = binvar(timeline,1);
%% Csp
H_csp = sdpvar(timeline,1);
gen_csp = sdpvar(timeline,1);
%%
constraints = [];

constraints = [constraints, H_csp/SL_c2s + gen_csp/SL_dch <= (k__in/(Min_discharge_period))*radiation];

% constraints = [constraints, 0 <= H_csp/SL_c2s + gen_csp/SL_dch <= k__csp*eta_csp*radiation*mu];
% constraints = [constraints, 0 <= gen_csp <= SL_dch*(k__csp*eta_csp*radiation - H_csp)];
% Max Generation
constraints = [constraints, gen <= repmat(mpc.gen(:,9),1,timeline)];
% Sell (Profit)
constraints = [constraints, ld <= D_matrix];
% power equality
constraints = [constraints, sum(gen,1) + (dch-ch)' + gen_csp' == sum(ld,1)];%%%%%%%%%%%%%%%%
% Existed Energy 
constraints = [constraints, e__st(2:end) == storage_efficiency *...
    e__st(1:end-1) + SL_ch*ch(2:end) - (1/SL_dch)*dch(2:end) + H_csp(1:end-1)];%%%%%%%%%%%%%%%%%%
% storage ramp rate
% constraints = [constraints, -Storage_Ramp_rate <= e__st(2:end) -...
%     e__st(1:end-1) <= Storage_Ramp_rate ];
% only one switch can work
constraints = [constraints, u(:) + v(:) <= 1];
% big m method of upper bound for discharge
constraints = [constraints, alpha <= M*u];

constraints = [constraints, alpha <= repelem((k__in/Min_discharge_period),T)'];

constraints = [constraints, alpha >= repelem((k__in/Min_discharge_period),T)' - M*(1-u)];

constraints = [constraints, alpha >= 0];
% big m method of upper bound for charge
constraints = [constraints, beta <= M*v];

constraints = [constraints, beta <= repelem((k__in/Min_charge_period),T)'];

constraints = [constraints, beta >= repelem((k__in/Min_charge_period),T)' - M*(1-v)];

constraints = [constraints, beta >= 0];

constraints = [constraints, (0 <= dch),((1/SL_dch)*dch <= alpha)];

constraints = [constraints, (0 <= ch),(SL_ch*ch + H_csp <= beta)];
% % discharge period rate
% constraints = [constraints, dch <= (k__in/Min_discharge_period)];
% % charge period rate
% constraints = [constraints, ch<= (k__in/Min_charge_period)];
% generator ramp rate
constraints = [constraints, gen(:,2:end) -...
    gen(:,1:end-1) <= repmat([80;80;80;50;50;50;30;30;30;30],1,timeline-1)];

constraints = [constraints, -repmat([80;80;80;50;50;50;30;30;30;30],1,timeline-1) <= gen(:,2:end) -...
    gen(:,1:end-1)];
% security -> line flow (PTDF)

constraints = [constraints, -repmat(mpc.branch(:,6),[1 T]) <= ...
    PTDF*([zeros(numnode-numgen,timeline); gen] - ld - ...
    [zeros(9,timeline);ch'; zeros(29,timeline)] + [zeros(9,timeline); dch'; zeros(29,timeline)]...
    + [ zeros(9,timeline); gen_csp'; zeros(29,timeline)])];

constraints = [constraints, PTDF*([zeros(numnode-numgen,timeline); gen] - ld - ...
    [zeros(9,timeline);ch'; zeros(29,timeline)] + [zeros(9,timeline); dch'; zeros(29,timeline)]...
    + [ zeros(9,timeline); gen_csp'; zeros(29,timeline)])<= repmat(mpc.branch(:,6),[1 T])];

% Spinning Reserve
% constraints = [constraints, sum(mpc.gen(:,9)) - sum(ld,1) >= Spinning_Reserve];
% constraints = [constraints, (alpha - dch)' + ch' +...
%     sum(repmat(mpc.gen(:,9),1,timeline) -  gen,1) + sum(ld,1) >= Spinning_Reserve];
%constraints = [constraints, (alpha-dch)' + ch' + sum(repmat(mpc.gen(:,9),1,timeline) -  gen,1) >= Spinning_Reserve];

%constraints = [constraints, (beta-ch)' + dch' + sum(gen,1) >= Spinning_Reserve];
%constraints = [constraints, sum(mpc.gen(:,9),1) - sum(gen,1) >= Spinning_Reserve];
constraints = [constraints, sum(repmat(mpc.gen(:,9),1,timeline) - gen,1) + (alpha*SL_dch - dch)' + ...
    ch'  >= Spinning_Reserve];
% bounds
constraints = [constraints, e__st(1:1) == 0, k__in >= e__st , e__st >= 0 ,v>=0, u>=0 ,...
     H_csp >= 0, gen_csp>=0, gen >= 0 , ld >= 0];


constraints = [constraints, gen_csp + dch <= SL_dch*(k__in/(Min_discharge_period))];
%%
%Ob_social_welfare = - sum(P__MAX .* sum(ld,1));

% Ob_Fuel_Cost = sum(sum(repmat(mpc.gencost(:,5),1,timeline) .* gen.^2 +...
%     repmat(mpc.gencost(:,6),1,timeline) .* gen +...
%     repmat(mpc.gencost(:,7),1,timeline)));
% Ob_Fuel_Cost = sum(sum(0.004447 .* gen.^2 +...
%     12.400 .* gen +...
%     323.100));
Ob_social_welfare = - sum(P__MAX .* sum(ld,1));

%Ob_Fuel_Cost = sum(sum( 0.01.* gen.^2 + 0.2 .* gen +0.3));
Ob_Fuel_Cost = sum(sum( 54 .* gen ));

Ob_investment = ((Storage_Investment)*k__in)/(Min_discharge_period) + 22*(sum(dch)) + 22*(sum(gen_csp)); % investment and om

%Ob_investment_csp = (CSP_Investment)*k__in__csp +  22*(sum(gen_csp));% investment and om

Ob_spinning_reserve = sum(8760*40*Spinning_Reserve);

Ob_OM = sum(sum(15 .* gen));

Ob_pen = 5*sum(P__MAX.*sum(D_matrix - ld,1));

Objective =  Ob_social_welfare + Ob_Fuel_Cost + Ob_investment +...
     Ob_spinning_reserve + Ob_OM + Ob_pen;