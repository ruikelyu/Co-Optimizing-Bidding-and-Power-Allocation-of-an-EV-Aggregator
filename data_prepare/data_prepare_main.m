%% ׼���������(����EV�������г��۸�RegD�źţ�
param = {}; % Initialize the parameter structure
root = fileparts(fileparts(mfilename("fullpath")));
addpath(fullfile(root, "data_prepare"));

%

%% ��ȡRegD�ź�����
% ʱ��������24Сʱ��������ֻȡ16��Сʱ��
NOFSLOTS = 16;

% ѡ������Ϊ7��17��-18��
if ~exist('day_price')
    day_price = 27; % Corresponding price: May 20th
    day_reg = day_price; % Frequency regulation signal: July 17th, 2020
end

hour_init = 18; % Starting from 18:00-19:00 (the original 19th slot)

% ��excel��ȡRegD�ź�����
filename = fullfile(root, "data_prepare", "07 2020.xlsx");
sheet = 'Dynamic'; % Specify the sheet
xlRange = 'B2:AF43202'; % Range

% ��ȡ7�·������ź����ݣ�2sһ���� * 31d
Signals = xlsread(filename, sheet, xlRange);

% �����������ų�������-1�� 1��������
Signals(Signals < -1) = -1;
Signals(Signals > 1) = 1;

% ����RegD���ݣ���������Сʱ�ķֲ�
data_handle_regd;

%% EV����
% ��ȡEV��������
data_generate_ev;

param.EV_arrive_leave = EV_arrive_leave;

% EV����
NOFEV = length(param.EV_arrive_leave);
% ��������
NOFSCEN = length(param.hourly_Distribution(1, :));

% ��Ƶ����
param.s_perf = 0.984;% �ο�PJM�̳��趨�Ĺ̶�ֵ
% �����(kW)������������(kWh)
param.P_max = 7.68;

for idx = 1 : NOFEV
    switch mod(idx, 3)
        case 1
            % ��ŵ�Ч��
            param.eta(idx) = 0.95;
            % �����(kW)������������(kWh)
            param.E_max(idx) = 90;
            % �ŵ��ϻ��ɱ�($/kWh)
            param.Pr_deg(idx) = 0.1;
        case 2
            % ��ŵ�Ч��
            param.eta(idx) = 0.92;
            % �����(kW)������������(kWh)
            param.E_max(idx) = 60;
            % �ŵ��ϻ��ɱ�($/kWh)
            param.Pr_deg(idx) = 0.15;
        case 0
            % ��ŵ�Ч��
            param.eta(idx) = 0.90;
            % �����(kW)������������(kWh)
            param.E_max(idx) = 36;
            % �ŵ��ϻ��ɱ�($/kWh)
            param.Pr_deg(idx) = 0.2;
    end
end
param.Pr_deg = param.Pr_deg';
param.eta = param.eta';
param.E_max = param.E_max';
param.E_0 = param.E_max / 3;
param.E_min = param.E_max / 6;
param.E_leave = param.E_max * 0.9;

% ���״̬ u
u = zeros(NOFEV, NOFSLOTS);
for idx = 1 : NOFEV
    for jdx = 1 : NOFSLOTS
        if param.EV_arrive_leave(idx, 2) <= jdx && jdx <= param.EV_arrive_leave(idx, 3)
            u(idx, jdx) = 1;
        end
    end
end
param.u = u;
clear u;

%% �г��۸����������
% ʱ�γ��ȣ�1Сʱ
delta_t = 1;

% ��ȡ��Ƶ�г��۸�����
filename = fullfile(root, "data_prepare", "regulation_market_results.xlsx");
sheet = 'regulation_market_results'; % Specify the sheet
start_row = (day_price-1) * 24 + hour_init + 2; % Starting row
xlRange = "G" + start_row + ":H" + (start_row + NOFSLOTS - 1); % Range
param.price_reg = xlsread(filename, sheet, xlRange); % Capacity price, mileage price

% ��ȡϵͳ�����۸�����
filename = fullfile(root, "data_prepare", "rt_hrl_lmps.xlsx");
sheet = 'rt_hrl_lmps'; % Specify the sheet
xlRange = "I" + start_row + ":I" + (start_row + NOFSLOTS - 1); % Range
param.price_e = xlsread(filename, sheet, xlRange); % Capacity price, mileage price

clear price filename sheet xlRange start_row signal_length i idx jdx EV_arrive_leave
