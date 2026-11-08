%% 使用启发式乘子的方法
root = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(root));
diff = 0.1;
M = 1e3;
% 准备数据
if ~ exist('param')
    run(fullfile(root, "data_prepare", "data_prepare_main.m"));
end

% 更新步长
NOFTCAP = 900;
P_alloc = [];
P_unbal = [];
actualMil = zeros(NOFSLOTS, 1);
actualEnergy = zeros(NOFSLOTS, 1);
actualCost = zeros(NOFSLOTS, 1);

% 初始时段
warning('off')
t_cap = 0;
maxProfit_1;

% 中间时段
for t_cap = 1 : (NOFSLOTS - 1) * 1800
    
    if mod(t_cap, 1800) == 0 % 时段末尾，更新下一时段投标，但乘子不更新
        delta_t_rest = 0;
        maxProfit_t;
        Bid_P_cur = value(Bid_P(1, :));
        Bid_R_cur = value(Bid_R(1, :));
        Bid_R_rev = [Bid_R_rev; Bid_R_cur];
        Bid_P_rev = [Bid_P_rev; Bid_P_cur];
        E_rev = [E_rev, E_cur];
        
    else
        if mod(t_cap, 900) == 1 % 时段初或中间初，更新乘子并分配功率，但不更新当前时段投标
            delta_t_rest = delta_t - mod(t_cap - 1, 1800) / 1800;% 当前时段剩余时间
            maxProfit_t; 
            heuristicAllocation;% 功率分配
        end
    end
end

% 最后一个时段，不用再投标
for t_cap = (NOFSLOTS - 1) * 1800 + 1 : NOFSLOTS * 1800 - 1
    if mod(t_cap, 900) == 1 % 时段初或中间初，分配功率
        lambda = zeros(NOFEV, 1);
        heuristicAllocation;% 功率分配
    end
end

E_rev = [E_rev, E_cur];

%计算收益
cal_profit;

save(fullfile(root, "results", "result_heuristic.mat"), "actualProfit","actualCost", ...
    "Bid_P_rev","Bid_R_rev","Bid_P_init","Bid_R_init", ...
    "actualEnergy","actualMil","P_alloc");
