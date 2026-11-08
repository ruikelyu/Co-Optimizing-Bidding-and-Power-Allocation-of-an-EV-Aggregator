%% ������һʱ��Ͷ�������У���ص�����Ӱ�Ӽ۸����ڵ�ǰʱ�ν��з���

% �������׵������������ձ��������Ƶ�ź�

% ���룺��ʱ����������Ƶ�г��۸񣻵綯��������뿪��ʱ�Ρ���������ǰʱ��ʱ��t_cap; ��ǰʱ�ε�Ͷ����
% ���룺��ǰ����ص�����
% ��ֵ�� ��һʱ��Ͷ��ʱ����ʱ�ε�Ͷ������
% ���:  δ����ʱ��Ͷ��������ص�����δ��һ��ʱ��L����


%% �����趨

% ���ࣺ�� data_prepare.m

% ��ǰʱ�α�� CUR_SLOT
CUR_SLOT = ceil(t_cap / 1800);% 2sһ��������1800����ȡ����Ϊ��ǰʱ�α��
% ʣ��ʱ������
REST_SLOTS = NOFSLOTS - CUR_SLOT;

%% ����
% Ͷ����������������Ƶ(MW), ��t + 1��T, ����t + 1Ϊ��һ��entry
Bid_P = sdpvar(REST_SLOTS, NOFEV, 'full'); 
Bid_R = sdpvar(REST_SLOTS, NOFEV, 'full'); 

% ��������
P_dis = sdpvar(NOFEV, REST_SLOTS + 1, NOFSCEN, 'full'); % EV�ڸ������ŵ繦��(kW),��ǰʱ��ʣ��ʱ����ȻҪ���䣬��˶�һ��ʱ��ά��
P_ch = sdpvar(NOFEV, REST_SLOTS + 1, NOFSCEN, 'full'); % EV�ڸ�������繦��(kW),��ǰʱ��ʣ��ʱ����ȻҪ���䣬��˶�һ��ʱ��ά��
E = sdpvar(NOFEV, REST_SLOTS + 2, 'full'); % EV�ڸ�ʱ��֮���ĵ������(kWh)��������ǰʱ�̡��뿪ʱ�̣���˶�2��ά��
Cost_deg = sdpvar(REST_SLOTS + 1, NOFSCEN, 'full');% δ����ʱ�θ����������ܳɱ�($/h)
delta_P_dis = sdpvar(NOFEV, 1, NOFSCEN, 'full'); % ƫ���(kW)
delta_P_ch = sdpvar(NOFEV, 1, NOFSCEN, 'full'); % ƫ���(kW)

%% Ŀ�꺯��
% �������桢��Ƶ�������桢��Ƶ������桢����ɱ������ܳɱ�
Profit = sum(param.price_e(CUR_SLOT + 1 : end)' * Bid_P + param.price_reg(CUR_SLOT + 1 : end, 1)' * Bid_R * param.s_perf + ...
    (param.price_reg(CUR_SLOT + 1 : end, 2) .* param.hourly_Mileage(CUR_SLOT + 1 : end))' * Bid_R * param.s_perf + ...
     ((param.hourly_Distribution(CUR_SLOT + 1 : end, :) * param.d_s) .* param.price_e(CUR_SLOT + 1 : end))' * Bid_R) - ...
     sum(sum(param.hourly_Distribution(CUR_SLOT + 1 : end, :) .* Cost_deg(2 : end, :)));
 
% ����ʱ�γ���
Profit = Profit * delta_t;

%���ϵ�ǰʱ�εĳɱ�
Profit = Profit - sum(((param.hourly_Distribution(CUR_SLOT, :) * param.d_s) .* param.price_e(CUR_SLOT))' * Bid_R_cur * delta_t_rest) - ...
     sum(sum(param.hourly_Distribution(CUR_SLOT, :) .* Cost_deg(1, :))) * delta_t_rest;



%% Լ������

Constraints = [];

% ��ǰ�������ɴ��Ƴ�L����
Constraints = [Constraints, E_cur - E(:, 1) == 0];

% ��Ƶ�����Ǹ��� NOFSLOTS
Constraints = [Constraints, 0 <= Bid_R];

% ������Ӧ-������ƽ�⡣ NOFEV * REST_SLOTS + 1 * NOFSCEN
temp = repmat(param.d_s', REST_SLOTS + 1, 1, NOFEV);
temp = permute(temp, [3, 1, 2]);

Constraints = [Constraints, 1e3 * repmat(Bid_P', 1, 1, NOFSCEN) + ...
    1e3 * repmat(Bid_R', 1, 1, NOFSCEN) .* temp(:, 2 : end, :) - (P_dis(:, 2 : end, :) - P_ch(:, 2 : end, :)) == 0];
Constraints = [Constraints, 1e3 * repmat(Bid_P_cur', 1, 1, NOFSCEN) + ...
    1e3 * repmat(Bid_R_cur', 1, 1, NOFSCEN) .* temp(:, 1, :) - (delta_P_dis - delta_P_ch + P_dis(:, 1, :) - P_ch(:, 1, :)) == 0];% ��ǰʱ��

% ����������(kW)�� NOFEV * NOFSLOTS * NOFSCEN
Constraints = [Constraints, 0 <= P_dis];
Constraints = [Constraints, 0 <= P_ch];
Constraints = [Constraints, P_dis(:, 2 : end, :) <= repmat(param.u(:, CUR_SLOT+1 : end), 1, 1, NOFSCEN) * param.P_max];
Constraints = [Constraints, P_ch(:, 2 : end, :) <= repmat(param.u(:, CUR_SLOT+1 : end), 1, 1, NOFSCEN) * param.P_max];
Constraints = [Constraints, P_dis(:, 1, :) <= (1 + 1e-5) * repmat(param.u(:, CUR_SLOT), 1, 1, NOFSCEN) * param.P_max];% ������ֵ����
Constraints = [Constraints, P_ch(:, 1, :) <= (1 + 1e-5) * repmat(param.u(:, CUR_SLOT), 1, 1, NOFSCEN) * param.P_max];

Constraints = [Constraints, 0 <= delta_P_dis];
Constraints = [Constraints, 0 <= delta_P_ch];

%  �ŵ��ϻ�($/h) .REST_SLOTS + 1 * NOFSCEN
temp = permute(sum(repmat(param.Pr_deg, 1, REST_SLOTS + 1, NOFSCEN) .* P_dis), [2, 3, 1]);% ��EV�Ĺ��ʾۺ�, �������� 
temp = reshape(temp, REST_SLOTS + 1, NOFSCEN);

Constraints = [Constraints, Cost_deg == temp];

% ʱ�μ���������(kWh)

% �뿪ʱ����Ϊ90%�ĵ����������У� NOFEV
Constraints = [Constraints, E(:, end) >= param.E_leave];

% �м�ʱ�ε�������10~60֮�� NOFEV * REST_SLOTS+2
Constraints = [Constraints, repmat(param.E_min, 1, REST_SLOTS + 2) <= E];
Constraints = [Constraints, E <= repmat(param.E_max, 1, REST_SLOTS + 2)];

% ��ƵͶ�����������Լ�� REST_SLOTS, ��t+1��2����ʼ
Constraints = [Constraints, repmat(param.eta, 1, REST_SLOTS) .* (E(:, 2 : end-1) - repmat(param.E_min, 1, REST_SLOTS)) ...
    >= 1e3 * Bid_R' * 0.25 * delta_t + 1e3 * Bid_P' * delta_t];
Constraints = [Constraints, repmat(1 ./ param.eta, 1, REST_SLOTS) .* (- E(:, 2 : end-1) + repmat(param.E_max, 1, REST_SLOTS)) ...
    >= 1e3 * Bid_R' * 0.25 * delta_t - 1e3 * Bid_P' * delta_t];

% ǰ��ʱ���ν� NOFEV * REST_SLOTS+1
temp = P_ch .* repmat(param.eta, 1, REST_SLOTS + 1, NOFSCEN) - ...
    P_dis .* repmat(1 ./ param.eta, 1, REST_SLOTS + 1, NOFSCEN);
temp = permute(temp, [3, 2, 1]);% ��������
temp = reshape(temp, NOFSCEN, (REST_SLOTS + 1) * NOFEV);% ������ƽΪ SCEN * (SLOTS * EV)
temp2 = repmat(param.hourly_Distribution(CUR_SLOT : end, :)', 1, NOFEV);% �ֲ��ظ�Ϊ SCEN * (SLOTS+1 * EV)
temp = sum(temp .* temp2);% ��ˣ��������ʼ�Ȩ���
temp = reshape(temp, REST_SLOTS + 1, NOFEV)';% ����дΪ SLOTS+1 * EV,��ת��ΪEV * SLOTS+1

Constraints = [Constraints, E(:, 3 : end) == E(:, 2 : end - 1) + temp(:, 2 : end) * delta_t];% δ��ʱ��
Constraints = [Constraints, E(:, 2) == E(:, 1) + temp(:, 1) * delta_t_rest];% δ��һ��ʱ��


%% ���solve
if ~exist("SOLVER_NAME", "var")
    SOLVER_NAME = 'cplex';
end
ops = sdpsettings('debug',1,'solver',SOLVER_NAME,'savesolveroutput',1,'savesolverinput',1);

% ���ʲ�ƽ��ͷ�
% M = 1e3;
Cost_s = M * sum(sum(delta_P_dis +  delta_P_ch));

sol = optimize(Constraints, - Profit + Cost_s, ops);

if sol.problem == 0 || sol.problem == 4% ���ɹ�
    disp(" ʱ��" + (CUR_SLOT+1) + " :Ͷ����ɡ�")
else
    disp("ʱ��" + (CUR_SLOT+1) + " :Ͷ���Ż�ʧ�ܡ�")
end
