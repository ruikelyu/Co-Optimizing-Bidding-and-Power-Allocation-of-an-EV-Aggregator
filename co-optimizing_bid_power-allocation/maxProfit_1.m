%% ��ͨͶ�꣬��ʱ��1��ʼ

% ���ڣ�1����ֵ������2�������������ճ���

% ���룺��ʱ����������Ƶ�г��۸񣻵綯��������뿪��ʱ�Ρ�������
% �������ʱ��Ͷ��������ص���

%% �����趨

% �� data_prepare_main.m

%% ����
% Ͷ����������������Ƶ(MW)
Bid_P = sdpvar(NOFSLOTS, 1, 'full'); 
Bid_R = sdpvar(NOFSLOTS, 1, 'full'); 

% ��������
P_dis = sdpvar(NOFEV, NOFSLOTS, NOFSCEN, 'full'); % EV�ڸ������ŵ繦��(kW)
P_ch = sdpvar(NOFEV, NOFSLOTS, NOFSCEN, 'full'); % EV�ڸ�������繦��(kW)
E = sdpvar(NOFEV, NOFSLOTS + 1, 'full'); % EV�ڸ�ʱ��֮���ĵ������(kWh)�������뿪ʱ��(ʱ�γ�)����˶�һ��ά��
Cost_deg = sdpvar(NOFSLOTS, NOFSCEN, 'full'); % ��ʱ�θ��������ϻ��ɱ�($)

%% Ŀ�꺯��
% �������桢��Ƶ�������桢��Ƶ������桢����ɱ������ܳɱ�
Profit = param.price_e' * Bid_P + param.price_reg(:, 1)' * Bid_R * param.s_perf + ...
    (param.price_reg(:, 2) .* param.hourly_Mileage)' * Bid_R * param.s_perf + ...
    ((param.hourly_Distribution * param.d_s) .* param.price_e)' * Bid_R - ...
    sum(sum(param.hourly_Distribution .* Cost_deg));
% ����ʱ�γ���
Profit = Profit * delta_t;

%% Լ������

Constraints = [];

% ���Ϊ�ﵽʱ�ĵ���(������) NOFEV����Լ���Ķ�ż����Ϊlambda
Constraints = [Constraints, E(:, 1) == param.E_0];

% ��Ƶ�����Ǹ��� NOFSLOTS
Constraints = [Constraints, 0 <= Bid_R];

% ������Ӧ-������ƽ�� NOFSLOTS * NOFSCEN
temp = permute(sum(P_dis - P_ch), [2, 3, 1]); % ��EV�Ĺ��ʾۺ�
temp = reshape(temp, NOFSLOTS, NOFSCEN);

Constraints = [Constraints, 1e3 * repmat(Bid_P, 1, NOFSCEN) + ...
    1e3 * repmat(Bid_R, 1, NOFSCEN) .* repmat(param.d_s', NOFSLOTS, 1) - temp == 0];
    
% ����������(kW). NOFEV * NOFSLOTS * NOFSCEN
Constraints = [Constraints, 0 <= P_dis];
Constraints = [Constraints, 0 <= P_ch];
Constraints = [Constraints, P_dis <= repmat(param.u, 1, 1, 22) * param.P_max];
Constraints = [Constraints, P_ch <= repmat(param.u, 1, 1, 22) * param.P_max];

% �ŵ��ϻ�($) NOFSLOTS * NOFSCEN
temp = permute(sum(repmat(param.Pr_deg, 1, NOFSLOTS, NOFSCEN) .* P_dis), [2, 3, 1]); % ��EV�Ĺ��ʾۺ�, ��������
temp = reshape(temp, NOFSLOTS, NOFSCEN);

Constraints = [Constraints, Cost_deg == temp];

% ʱ�μ���������(kWh)
% �뿪ʱ����Ϊ90%�ĵ����������У� NOFEV
Constraints = [Constraints, E(:, end) >= param.E_leave];

% �м�ʱ�ε������������С֮�� NOFEV * NOFSLOTS
Constraints = [Constraints, repmat(param.E_min, 1, NOFSLOTS + 1) <= E];
Constraints = [Constraints, E <= repmat(param.E_max, 1, NOFSLOTS + 1)];

% ��ƵͶ�����������Լ�� NOFSLOTS
Constraints = [Constraints, param.eta' * (E(:, 1 : end - 1) - repmat(param.E_min, 1, NOFSLOTS)) >= 1e3 * Bid_R' * 0.25 * delta_t + 1e3 * Bid_P' * delta_t];
Constraints = [Constraints, (1 ./ param.eta)' * (- E(:, 1 : end - 1) + repmat(param.E_max, 1, NOFSLOTS)) >= 1e3 * Bid_R' * 0.25 * delta_t - 1e3 * Bid_P' * delta_t];

% ǰ��ʱ���ν� NOFEV * NOFSLOTS
temp = P_ch .* repmat(param.eta, 1, NOFSLOTS, NOFSCEN) - ...
    P_dis .* repmat(1 ./ param.eta, 1, NOFSLOTS, NOFSCEN);
temp = permute(temp, [3, 2, 1]); % ��������
temp = reshape(temp, NOFSCEN, NOFSLOTS * NOFEV); % ������ƽΪ SCEN * (SLOTS * EV)
temp2 = repmat(param.hourly_Distribution', 1, NOFEV); % �ֲ��ظ�Ϊ SCEN * (SLOTS * EV)
temp = sum(temp .* temp2); % ��ˣ��������ʼ�Ȩ���
temp = reshape(temp, NOFSLOTS, NOFEV)'; % ����дΪ SLOTS * EV,��ת��ΪEV * SLOTS

Constraints = [Constraints, E(:, 2 : end) == E(:, 1 : end - 1) + temp * delta_t];

%% ���solve
if ~exist("SOLVER_NAME", "var")
    SOLVER_NAME = 'cplex';
end
ops = sdpsettings('debug', 1, 'solver', SOLVER_NAME, 'savesolveroutput', 1, 'savesolverinput', 1);

sol = optimize(Constraints, -Profit, ops);

if sol.problem == 0 % ���ɹ�
    disp("ʱ��1 :Ͷ�����.")
else 
    disp("ʱ��1 :Ͷ��ʧ��.")
end

%% ��¼
Bid_R_init = value(Bid_R);
Bid_P_init = value(Bid_P);
E_init = value(E);
Bid_R_cur = value(Bid_R(1));
Bid_P_cur = value(Bid_P(1));
E_cur = value(E(:, 1));

% ���ں����ļ�¼
Bid_R_rev = Bid_R_cur;
Bid_P_rev = Bid_P_cur;
E_rev = E_cur;
