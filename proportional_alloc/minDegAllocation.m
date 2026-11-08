%% 在4s一个的RegD信号到来后，给出每辆车的充放电功率(一次算1800个结果)
% 现有文献的做法，设置启发式权重分配信号
% 输入：当前中标容量Bid_R_cur, Bid_P_cur，RegD信号 delta，EV的当前电量 E_cur，电量的影子价格lambda
% 输入：当前时刻t_cap
% 输入：每辆EV的功率 P_dis, P

%% 参数设定

% 更多：见 data_prepare.m
% 模型见Real-Time Charging Management Framework for
% Electric Vehicle Aggregators in a
% Market Environment

% 当前时段编号 CUR_SLOT
CUR_SLOT = ceil(t_cap / 1800);% 4s一个，除以1800向上取整，为时段编号

% 各EV距离离开的时间
% 现在是时段初，离开为时段末尾，因此需要-1
REST_TIME = param.EV_arrive_leave(:, 3) - repmat(t_cap : t_cap - 1 + NOFTCAP, NOFEV, 1) / 1800;
REST_TIME(find(REST_TIME < 0)) = 0;


% delta = Signal_day((CUR_SLOT - 1) * 1800 + 1 : CUR_SLOT * 1800)';
delta = Signal_day(t_cap : t_cap + NOFTCAP - 1)';

%% 权重设置(见文献)
% x1 = 1;
% x2 = 1;
% y = 4;
% z = 5;
% E_r = param.E_leave - E_cur;% 待充电量
% E_r(find(E_r < 0)) = 0;% 去除负数
% T_r = REST_TIME(:, 1); % 剩余时间
% w_Er = 1 - (E_r /max(param.E_max)).^(1 / y);
% w_Tr = 1 - (T_r / max(param.EV_arrive_leave(:, 3) - param.EV_arrive_leave(:, 2))).^(1 / z);
% w = w_Er.^x1 .* w_Tr.^x2;


%% 变量
P_dis_s = sdpvar(NOFEV, NOFTCAP, 'full'); % EV放电功率(kW)
P_ch_s = sdpvar(NOFEV, NOFTCAP, 'full'); % EV充电功率(kW)

% 辅助变量
E_cap = sdpvar(NOFEV, NOFTCAP + 1, 'full'); % EV电量
delta_P_dis = sdpvar(1, NOFTCAP, 'full'); % 偏差功率(kW)
delta_P_ch = sdpvar(1, NOFTCAP, 'full'); % 偏差功率(kW)


%% 目标函数
% 性能成本、对未来收益的影响($/h)
% M = 1e3;

temp = P_ch_s .* repmat(param.eta, 1, NOFTCAP) - ...
    P_dis_s .* repmat(1 ./ param.eta, 1, NOFTCAP);

Cost_s = sum(param.Pr_deg' * P_dis_s) + ...
    M * sum(sum(delta_P_dis + delta_P_ch));


% 乘以时段长度(不影响结果，所以不乘了)
% Cost_s = Cost_s * delta_t_cap / 1800;

%% 约束条件

Constraints = [];

% 功率响应-各场景平衡
Constraints = [Constraints, 1e3 * repmat(sum(Bid_P_cur), 1, NOFTCAP) + ...
    1e3 * sum(Bid_R_cur) * delta - sum(P_dis_s - P_ch_s) - (delta_P_dis - delta_P_ch) == 0];

% 功率上下限(kW)
Constraints = [Constraints, 0 <= P_dis_s];
Constraints = [Constraints, 0 <= P_ch_s];
Constraints = [Constraints, P_dis_s <= repmat(param.u(:, CUR_SLOT) * param.P_max, 1, NOFTCAP)];
Constraints = [Constraints, P_ch_s <= repmat(param.u(:, CUR_SLOT) * param.P_max, 1, NOFTCAP)];

Constraints = [Constraints, 0 <= delta_P_dis];
Constraints = [Constraints, 0 <= delta_P_ch];

% 电量约束
% 电量衔接
Constraints = [Constraints, E_cap(:, 1) == E_cur];
Constraints = [Constraints, E_cap(:, 2 : end) == E_cap(:, 1 : end - 1) + temp * delta_t / 1800];

% 电量上下限
% 保证能充满
Constraints = [Constraints,  param.E_leave - repmat(param.eta, 1, NOFTCAP) .* REST_TIME * param.P_max <= E_cap(:, 2 : end)];

% % 中间时段的能量在10~60之间 NOFEV * NOFSLOTS
Constraints = [Constraints, repmat(param.E_min, 1, NOFTCAP + 1) <= E_cap];
Constraints = [Constraints, E_cap <= repmat(param.E_max, 1, NOFTCAP + 1)];

%% slove
if ~exist("SOLVER_NAME", "var")
    SOLVER_NAME = 'cplex';
end
ops = sdpsettings('debug',1,'solver',SOLVER_NAME,'savesolveroutput',1,'savesolverinput',1);

sol = optimize(Constraints, Cost_s, ops);

if sol.problem == 0 || sol.problem == 4 % 求解成功
    disp("时段" + CUR_SLOT + " :" + t_cap + "分配完成。")
else
    disp("时段" + CUR_SLOT + " :" + t_cap + "分配优化失败。")
end

%% 记录结果+更新电量

cal_allocation;


