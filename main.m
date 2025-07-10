clc
clear all
close all
yalmip('clear')

start_time = fix(clock);
disp(['Start Time: ', datestr(datetime(start_time))])
%% Define scenarios: [poss_flag, nec_flag, value]
senarios = [
    1 0 0.25;
    1 0 0.5;
    1 0 0.75;
    0 1 0;
    0 1 0.25;
    0 1 0.5;
    0 1 0.75
    ];

fprintf('Total %d scenarios defined.\n', size(senarios, 1));
fprintf('--------------------------\n');

for i = 1 : size(senarios, 1)
    scenario_start = tic;

    poss = senarios(i, 1);
    nec  = senarios(i, 2);
    val  = senarios(i, 3);

    % Set parameter based on scenario type
    if poss == 1
        p_inf = val;
        scenario_type = 'poss';
    elseif nec == 1
        p_inf = val;
        scenario_type = 'nec';
    end

    fprintf('\nStarting Scenario %1f: %s = %.2f\n', i, scenario_type, val);

    %% Load Variables
    run('Variable.m')
    disp('Variables Extracted!')

    %% Define Problem
    run('Problem_formulation_all_0318.m')
    disp('Problem Formulated!')

    %% Solver Options
    run('Solver_Options.m')
    disp('Solver Options Set!')

    %% Solve
    EXPORT = export(constraints, Objective, Options);
    diagnostics = optimize(constraints, Objective, Options);

    if diagnostics.problem == 0
        disp('Problem Solved Successfully!');
    else
        disp('Problem Did Not Solve Properly!');
        disp(diagnostics.info);
        disp(yalmiperror(diagnostics.problem));
    end

    %% Show Results
    run('Result_all.m')
    disp('Results Displayed!')

    %% Time per scenario
    scenario_time = toc(scenario_start);
    fprintf('Time for scenario %d: %.2f seconds\n', i, scenario_time);

    %% Save Results
    file_name = sprintf('sen0.2_%d_%s_%.2f', i, scenario_type, val);
    run('Save_Results_all.m')
    disp(['Result Saved as: ', file_name])

end

end_time = fix(clock);
disp('===========================')
disp('All Scenarios Completed.')
disp(['Start Time: ', datestr(datetime(start_time))])
disp(['End Time:   ', datestr(datetime(end_time))])
