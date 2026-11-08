function report = check_installation(varargin)
%CHECK_INSTALLATION Verify MATLAB, YALMIP, data, and solver availability.
%
% Name-value option:
%   "Solver"  "auto", "cplex", or "gurobi" (default "auto")

root = setup_project();
p = inputParser;
addParameter(p, "Solver", "auto", @(x) ischar(x) || isstring(x));
parse(p, varargin{:});

requestedSolver = lower(string(p.Results.Solver));
if requestedSolver == "auto"
    if exist("gurobi", "file") == 2
        solver = "gurobi";
    elseif exist("cplexlp", "file") == 2 || exist("cplexoptimset", "file") == 2
        solver = "cplex";
    else
        solver = "none";
    end
else
    solver = requestedSolver;
end

report = struct();
report.matlabVersion = version;
report.matlabSupported = ~verLessThan("matlab", "24.2");
report.yalmipAvailable = exist("sdpvar", "file") == 2 && exist("optimize", "file") == 2;
report.solver = solver;
report.solverAvailable = (solver == "gurobi" && exist("gurobi", "file") == 2) || ...
    (solver == "cplex" && (exist("cplexlp", "file") == 2 || exist("cplexoptimset", "file") == 2));
requiredFiles = {
    fullfile(root, "data_prepare", "07 2020.xlsx")
    fullfile(root, "data_prepare", "EV_arrive_leave.xlsx")
    fullfile(root, "data_prepare", "rt_hrl_lmps.xlsx")
    fullfile(root, "data_prepare", "regulation_market_results.xlsx")
    fullfile(root, "co-optimizing_bid_power-allocation", "main.m")
    };
report.filesAvailable = all(cellfun(@isfile, requiredFiles));
report.ok = report.matlabSupported && report.yalmipAvailable && ...
    report.solverAvailable && report.filesAvailable;

fprintf("MATLAB %s: %s\n", report.matlabVersion, statusText(report.matlabSupported));
fprintf("YALMIP: %s\n", statusText(report.yalmipAvailable));
fprintf("Selected solver (%s): %s\n", solver, statusText(report.solverAvailable));
fprintf("Repository data and scripts: %s\n", statusText(report.filesAvailable));

if ~report.matlabSupported
    fprintf("  Requires MATLAB R2024b or newer.\n");
end
if ~report.yalmipAvailable
    fprintf("  Install YALMIP and add it to the MATLAB path.\n");
end
if ~report.solverAvailable
    fprintf("  Install CPLEX or Gurobi and its MATLAB/YALMIP interface.\n");
end
if ~report.filesAvailable
    fprintf("  One or more bundled data or model files are missing.\n");
end
if ~report.ok
    error("EV:InstallationIncomplete", ...
        "Installation is incomplete. Resolve the messages above before running the model.");
end
end

function text = statusText(value)
if value
    text = "OK";
else
    text = "MISSING";
end
end
