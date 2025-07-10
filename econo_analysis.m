clc;
clear;

% Set default styles
set(0, 'DefaultAxesFontName', 'Times New Roman', ...
       'DefaultAxesFontWeight', 'bold', ...
       'DefaultAxesFontSize', 13, ...
       'DefaultLineLineWidth', 1.2);

% Define all scenarios [poss nec value]
senarios = [
    1 0 0.25;
    1 0 0.5;
    1 0 0.75;
    0 1 0;
    0 1 0.25;
    0 1 0.5;
    0 1 0.75;
];

fprintf('Total %d scenarios defined.\n', size(senarios, 1));
fprintf('--------------------------\n');

% Preallocate results structure
results = [];

for i = 1 : size(senarios, 1)
    scenario_start = tic;

    poss = senarios(i, 1);
    nec  = senarios(i, 2);
    val  = senarios(i, 3);

    % Determine scenario type and set value
    if poss == 1
        p_inf = val;
        scenario_type = 'poss';
    elseif nec == 1
        p_inf = val;
        scenario_type = 'nec';
    else
        p_inf = 0;
        scenario_type = 'none';
    end

    % Define file name (if needed for parameters — not Res!)
    paramFile = sprintf('sen39_%s_%.2f.mat', scenario_type, val);
    
    % Load only parameters from file, NOT Res
    if isfile(paramFile)
        load(paramFile);  % Make sure this doesn't contain 'Res' that overwrites
    else
        warning('File %s not found. Skipping.', paramFile);
        continue;
    end

    % Run the Variable.m script which creates Res
    run('Variable.m');

    % Check if Res exists
    if ~exist('Res', 'var')
        warning('Res not found after Variable.m run for scenario %d.', i);
        continue;
    end

    % Extract from Res
    gen         = Res{1,1};
    ld          = Res{1,2};
    ch          = Res{1,3};
    dch         = Res{1,4};
    e__st       = Res{1,5};
    k__in       = Res{1,6};
    u           = Res{1,7};
    v           = Res{1,8};
    Objective   = Res{1,9};
    D_matrix    = Res{1,10};
    mpc         = Res{1,11};
    k__csp      = Res{1,12};
    H_csp       = Res{1,13};
    gen_csp     = Res{1,14};

    % Assume these are defined globally or inside Variable.m
    try
        Ob_social_welfare = -sum(P__MAX .* sum(ld, 1));
        Ob_Fuel_Cost = sum(sum(54 .* gen));
        Ob_investment = ((Storage_Investment) * k__in) / (Min_discharge_period) + ...
                         22 * sum(dch) + 22 * sum(gen_csp);
        Ob_spinning_reserve = sum(8760 * 40 * Spinning_Reserve);
        Ob_OM = sum(sum(15 .* gen));
        Ob_pen = 5 * sum(P__MAX .* sum(D_matrix - ld, 1));

        Objective = Ob_social_welfare + Ob_Fuel_Cost + Ob_investment + ...
                    Ob_spinning_reserve + Ob_OM + Ob_pen;
    catch err
        warning('Some variables (like P__MAX or Spinning_Reserve) missing. Skipping scenario %d.', i);
        continue;
    end
    Objective=-Objective;
    % Calculate financial indicators
    revenue = sum(P__MAX' .* value(dch + gen_csp));
    purchase_cost = sum(P__MAX .* ch');
    maintenance_cost = 22 * sum(dch) + 22 * sum(gen_csp);
    investment_cost = ((Storage_Investment) * k__in) / Min_discharge_period;
    net_profit = revenue - purchase_cost - maintenance_cost - investment_cost;
    profit_percent = (net_profit / (purchase_cost + maintenance_cost + investment_cost)) * 100;

    % Store results
results = [results; struct( ...
    'Scenario', scenario_type, ...
    'Level', val, ...
    'InvestmentProfitPercent', profit_percent, ...
    'NetProfit', net_profit, ...
    'RevenueFromSelling', revenue, ...
    'PurchaseCostForCharging', purchase_cost, ...
    'MaintenanceCost', maintenance_cost, ...
    'InvestmentCost', investment_cost, ...
    'K_str', k__in, ...
    'K_csp', k__in/8, ...
    'Objective',Objective, ...
    'time', Res{1,15} ...
)];
    fprintf('Scenario %d done in %.2f seconds.\n', i, toc(scenario_start));
end

% Display results
resultsTable = struct2table(results);
disp('--- Financial Summary Table ---');
disp(resultsTable);
