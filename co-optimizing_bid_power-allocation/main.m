%% Ͷ��-���ʷֽ������Ż�������

M = 1e3; % ����
root = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(root));
if ~exist("SOLVER_NAME", "var")
    SOLVER_NAME = 'cplex';
end

% ׼������
run(fullfile(root, "data_prepare", "data_prepare_main.m")); % ��������׼������

% Ͷ����²���
NOFTCAP = 900; % ��Ӧ30����
P_alloc = []; % ���ڼ�¼���ʷ�����
actualMil = zeros(NOFSLOTS, 1); % ��¼ʵ�ʵ�Ƶ���
actualEnergy = zeros(NOFSLOTS, 1); % ��¼ʵ���������������
actualCost = zeros(NOFSLOTS, 1); % ��¼ʵ���ϻ��ɱ�

% ��ʼʱ��
warning('off')
t_cap = 0;
maxProfit_1; % �����ʼʱ���������

% �м�ʱ��
for t_cap = 1 : (NOFSLOTS - 1) * 1800
    
    if mod(t_cap, 1800) == 0 % ʱ��ĩβ��������һʱ��Ͷ�꣬�����Ӳ�����
        delta_t_rest = 0;
        maxProfit_t; % ������һʱ���������
        % ��¼��ؽ��
        Bid_P_cur = value(Bid_P(1));
        Bid_R_cur = value(Bid_R(1));
        Bid_R_rev = [Bid_R_rev; value(Bid_R(1))];
        Bid_P_rev = [Bid_P_rev; value(Bid_P(1))];
        E_rev = [E_rev, E_cur];
        
    else
        if mod(t_cap, 900) == 1 % ʱ�γ����м�������³��Ӳ����书�ʣ��������µ�ǰʱ��Ͷ��
            delta_t_rest = delta_t - mod(t_cap - 1, 1800) / 1800; % ��ǰʱ��ʣ��ʱ��
            maxProfit_t; % ���㵱ǰʱ���������
            lambda = sol.solveroutput.lambda.eqlin(1 : NOFEV);
            minCostAllocation; % ���ʷ���
        end
    end
end

% ���һ��ʱ�Σ�������Ͷ��
for t_cap = (NOFSLOTS - 1) * 1800 + 1 : NOFSLOTS * 1800 - 1
    if mod(t_cap, 900) == 1 % ʱ�γ����м�������书��
        lambda = zeros(NOFEV, 1); % ������ֵ����
        minCostAllocation; % ���ʷ���
    end
end

E_rev = [E_rev, E_cur];

%% �г�����
actualProfit = param.price_e .* actualEnergy + param.price_reg(:, 1) .* Bid_R_rev * param.s_perf + ...
    (param.price_reg(:, 2) .* actualMil) * param.s_perf;
 % ����ʱ�γ���
actualProfit =  actualProfit * delta_t;

save(fullfile(root, "results", "result_my_alloc.mat"), "actualProfit", "actualCost", ...
    "Bid_P_rev", "Bid_R_rev", "Bid_P_init", "Bid_R_init", ...
    "actualEnergy", "actualMil", "P_alloc");
