![image](https://github.com/user-attachments/assets/e4b9800e-41d6-4a29-9a86-61b96b83bc3b)


# Optimizing Bidding and Power Allocation
Data and code for my paper "Co-Optimizing Bidding and Power Allocation of an EV Aggregator Providing Real-Time Frequency Regulation Service."

Citation: R. Lyu, H. Guo, K. Zheng, M. Sun, and Q. Chen, "Co-Optimizing Bidding and Power Allocation of an EV Aggregator Providing Real-Time Frequency Regulation Service," in IEEE Transactions on Smart Grid, vol. 14, no. 6, pp. 4594-4606, Nov. 2023, doi: 10.1109/TSG.2023.3252664.

### 项目简介

video: https://www.bilibili.com/video/BV1u3QDYFEKi/?vd_source=18e4b7b95b505bbe9bf571ca4ff73d55

这个GitHub仓库包含了与论文相关的代码，旨在提供编程思路和参考代码，以便解决问题或比较方法。请注意，这些代码主要作为参考，而不是一键运行并获得与论文完全相同的结果。仓库将会持续更新，而论文则不会。

### Introduction

This GitHub repository contains code related to the paper, aimed at providing programming insights and reference code for problem-solving or method comparison. Please note that these codes are primarily for reference and not intended to be run as-is to reproduce the exact results from the paper. The repository will be continuously updated, unlike the static nature of the paper.

### 主要测试部分

在 `co-optimizing_bid_power-allocation` 文件夹中，您可以找到以下主要测试部分：

- `main`: 主程序（投标 - 功率控制）。
- `maxProfit_1`: 前一天的最优投标程序。
- `maxProfit_t`: 实时最优投标程序（在某小时中间）。
- `minCostAllocation`: 最优分解问题。

这些测试部分提供了基本的演示，一旦您安装好环境，即可运行并了解基本场景。

### Main Testing Sections

In the `co-optimizing_bid_power-allocation` folder, you can find the following main testing sections:

- `main`: Main program (bidding - power control).
- `maxProfit_1`: Optimal bidding program for the previous day.
- `maxProfit_t`: Real-time optimal bidding program (in the middle of a certain hour).
- `minCostAllocation`: Optimal decomposition problem.

These testing sections offer a basic demo that can be run once you have set up the environment.

### Quick Start

Install MATLAB R2024b or newer, [YALMIP](https://yalmip.github.io/), and
either CPLEX or Gurobi with its MATLAB/YALMIP interface and a valid license.
Then run the following from any MATLAB current folder:

```matlab
cd('path/to/Co-Optimizing-Bidding-and-Power-Allocation-of-an-EV-Aggregator')
setup_project
check_installation
result = run_demo;
```

The default solver is selected automatically, preferring Gurobi and then
CPLEX. To select one explicitly:

```matlab
result = run_demo("Solver", "gurobi");
% or
result = run_demo("Solver", "cplex");
```

The simulation processes a full 16-hour horizon and may take a substantial
amount of time. Results are saved under `results/`. `run_demo` returns the
main result arrays in a MATLAB structure.

### 如何使用

安装 MATLAB R2024b 或更高版本、YALMIP，以及 CPLEX 或 Gurobi（含 MATLAB/YALMIP
接口和有效许可证），然后运行：

```matlab
cd('path/to/Co-Optimizing-Bidding-and-Power-Allocation-of-an-EV-Aggregator')
setup_project
check_installation
result = run_demo;
```

### How to Use

The legacy scripts remain available under `co-optimizing_bid_power-allocation`
and `proportional_alloc`. The wrappers above configure paths and select the
available solver automatically, so users do not need to edit scripts or change
folders manually.

### 说明文档

**开始之前:**

为了运行程序，您需要安装 MATLAB + YALMIP + CPLEX 或 Gurobi。
推荐使用仓库根目录中的 `setup_project`、`check_installation` 和 `run_demo`。
旧版代码默认使用 CPLEX；包装器会自动选择可用的求解器，因此通常不需要手动修改：
```matlab
ops = sdpsettings('debug',0,'solver','cplex','savesolveroutput',1,'savesolverinput',1);
```
改为：
```matlab
ops = sdpsettings('debug',0,'solver','gurobi','savesolveroutput',1,'savesolverinput',1);
```

**data_prepare:** 从原始数据中读取参数，并构建所需的参数矩阵（`param`）。
- `07 2020.xlsx`: PJM 2020年7月的 RegD 信号。
- `rt_hrl_lmps.xlsx`: PJM 市场数据：实时逐小时节点电价（来自 PJM 官网）。
- `regulation_market_results.xlsx`: PJM 市场数据：逐小时调频市场价格（来自 PJM 官网）。
- `EV_arrive_leave.xlsx`: 电动汽车到达数据（4000辆），来自 Li_Emission-Concerne_2013。
- `data_prepare_main`: 数据准备主程序。
- `data_generate_ev`: 准备 EV 参数**。
- `data_handle_regd`: 准备 RegD 信号和预测的分布**。

**co-optimizing_bid_power-allocation:** 主要程序。
- `main`: 主程序（投标 - 功率控制）**。
- `maxProfit_1`: 前一天的最优投标程序**。
- `maxProfit_t`: 实时最优投标程序（在某小时中间）**。
- `minCostAllocation`: 最优分解问题。

**proportional_alloc:** 对比现有文献中的一些方法（包括投标和功率分配）。具体细节请参考我们的论文。命名方式与我们的方法类似，因为并非我们提出的，所以仅供参考，没有详细解释。

**results:** 运行结果以 .mat 格式存储，相关可视化文件已省略。

对于基础认识，请关注标有 ** 的程序，了解：
1. 参数的确定（`param`）。
2. 最优投标程序和最优分解算法（`maxProfit_1`、`maxProfit_t`、`minCostAllocation`）。
3. 参与市场的整个流程（`main`）。

### ReadMe

Before getting started:

To run the program, you need MATLAB + YALMIP + CPLEX or Gurobi.
Run `setup_project`, `check_installation`, and `run_demo` from the repository
root to configure the path, verify dependencies, and run the main example.
The wrapper automatically prefers Gurobi and falls back to CPLEX. The legacy
scripts can still be run directly. If you need to select Gurobi manually, change:
```matlab
ops = sdpsettings('debug',0,'solver','cplex','savesolveroutput',1,'savesolverinput',1);
```
to:
```matlab
ops = sdpsettings('debug',0,'solver','gurobi','savesolveroutput',1,'savesolverinput',1);
```

The entire code comments are mainly written in Chinese. Only the English explanations of the files are provided in the ReadMe. If you need to delve into each line of code, you can use GPT to translate the comments.

- `data_prepare`: Reads parameters from raw data and constructs the required parameter matrix (`param`).
    - `07 2020.xlsx`: PJM's RegD signal for July 2020.
    - `rt_hrl_lmps.xlsx`: PJM market data: real-time hourly nodal prices (from the PJM official website).
    - `regulation_market_results.xlsx`: PJM market data: hourly regulation market prices (from the PJM official website).
    - `EV_arrive_leave.xlsx`: Data for EV arrivals (4000 vehicles), from Li_Emission-Concerne_2013.
    - `data_prepare_main`: Main data preparation program.
    - `data_generate_ev`: Prepares EV parameters**.
    - `data_handle_regd`: Prepares RegD signal and predicted distribution**.

- `co-optimizing_bid_power-allocation`: Main program.
    - `main`: Main program (bidding - power control)**.
    - `maxProfit_1`: Optimal bidding program for the previous day**.
    - `maxProfit_t`: Real-time optimal bidding program (in the middle of a certain hour)**.
    - `minCostAllocation`: Optimal decomposition problem.

- `proportional_alloc`: Some methods from existing literature for comparison (including bidding and power allocation). Details can be found in our paper. The naming is similar to our method, as it is not proposed by us, it is only included here for reference without detailed explanation.

- `results`: Results of the runs, stored in .mat format, visualization files are omitted.

For a basic understanding, focus on the programs marked with **, to understand:
1. Determining parameters (`param`).
2. Optimal bidding programs and optimal decomposition algorithms (`maxProfit_1`, `maxProfit_t`, `minCostAllocation`).
3. The entire process of participating in the market (`main`).
