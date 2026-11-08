%% ��excel��ȡEV����ʱ�䣬�����õ����ص���������
% Read EV arrival time from Excel and set other parameters related to the battery

root = fileparts(fileparts(mfilename("fullpath")));
filename = fullfile(root, "data_prepare", "EV_arrive_leave.xlsx");
sheet = 'EV_arrive_leave'; % ���ڱ��� Specify the sheet
xlRange = 'A2:C4013'; % ��Χ Range

EV_arrive_leave = xlsread(filename, sheet, xlRange); % EV��ţ� �ﵽʱ�Σ� �뿪ʱ�� EV number, arrival period, departure period
% �ı䳵������ 4012 => 400����Ϊ����Ҫ��ô��
% Change the number of vehicles from 4012 to 400, as not all are needed
EV_arrive_leave = EV_arrive_leave(1:10:end, :);

% �ı䵽����뿪ʱ��(�ڶ���)����Ϊԭʼ������15min���ȣ�������Сʱ����
% Change arrival and departure times (second column) from 15-minute granularity to hourly granularity
col = 2;
for i = 1:length(EV_arrive_leave)
    if EV_arrive_leave(i, col) ~= 1
        EV_arrive_leave(i, col) = ceil(EV_arrive_leave(i, col) / 4) + 2; % ����ʱ�䣬����ȡ�� Arrival time: rounded up
    end
    if EV_arrive_leave(i, col + 1) < 57
        EV_arrive_leave(i, col + 1) = floor((EV_arrive_leave(i, col + 1)) / 4) + 1; %�뿪ʱ�䣺����ȡ�� Departure time: rounded down
    end
    if EV_arrive_leave(i, col + 1) == 57
        EV_arrive_leave(i, col + 1) = 16;
    end
end
