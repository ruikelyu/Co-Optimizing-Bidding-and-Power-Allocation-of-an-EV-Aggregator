function root = setup_project()
%SETUP_PROJECT Add repository folders to the MATLAB path.

root = fileparts(mfilename("fullpath"));
addpath(genpath(root));

fprintf("Project path configured:\n%s\n", root);
fprintf("You can now run check_installation or run_demo.\n");
end
