function result = run_demo(varargin)
%RUN_DEMO Run the main EV aggregator simulation from any current folder.
%
% Name-value options:
%   "Solver"  "auto", "cplex", or "gurobi" (default "auto")

root = setup_project();
report = check_installation(varargin{:});
SOLVER_NAME = char(report.solver);
run(fullfile(root, "co-optimizing_bid_power-allocation", "main.m"));

result = struct();
result.actualProfit = actualProfit;
result.actualCost = actualCost;
result.Bid_P_rev = Bid_P_rev;
result.Bid_R_rev = Bid_R_rev;
result.actualEnergy = actualEnergy;
result.actualMil = actualMil;
result.P_alloc = P_alloc;
end
