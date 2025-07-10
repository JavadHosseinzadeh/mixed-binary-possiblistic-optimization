% yalmip options:
Options = sdpsettings('solver','CPLEX');
Options.verbose = 2;
Options.showprogress = 1;
Options.debug = 1;
%Options.relax=1;
% cplex options:
Options.cplex=cplexoptimset('cplex');
Options.cplex.display='on';
% Options.cplex.clocktype=1;
 % Options.cplex.advance=3;
%Options.cplex.mip.strategy.nodeselect =0 ;
%Options.cplex.preprocessing.relax=1;
%benders options:
 % Options.cplex.benders.strategy=3;