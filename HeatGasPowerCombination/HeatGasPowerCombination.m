clc;
clear;
close all;
clear all class;

addpath('./example');
addpath('./functions');
addpath('./HeatGasPowerCombination');

%%
% 读入
% casename = input('Please enter case name : ', 's');
% casename = 'case14mod_SCUC_parallel';
casename = 'HeatGasPowerSystem';
% casename = 'IEEE118_new';

% 安全系数，用于留一定的裕度，针对潮流安全约束
k_safe = 0.95;         

% 初始化文件
initial;

%%
%导纳矩阵计算
% [Ybus, Yf, Yt] = makeYbus(baseMVA, bus, M_branch);   % build admitance matrix
[Bbus, Bf, Pbusinj, Pfinj] = makeBdc(baseMVA, bus, branch);       %直流潮流
%%
% 创建决策变量
%%
% 电网
% 火电发电机出力 
gen_P = sdpvar(n_gen, n_T);
gen_P_upper = sdpvar(n_gen, n_T);

% 火电机组状态
u_state = binvar(n_gen, n_T);    

% 电力系统各支路功率
PF_D  = sdpvar(n_branch, n_T);
% 电力系统各节点相角
Va = sdpvar(n_bus,n_T);
%%
% 气网
GasFlow = sdpvar(n_GasBranch, n_T);         %各管道气流量
GasPressure2 = sdpvar(n_GasBus, n_T);       %各节点气压平方
GasSourceOutput = sdpvar(n_GasSource, n_T); %各天然气源节点出力
GasGenNeed = sdpvar(n_GasGen, n_T);         %各天然气发电机耗气

%%
% 热网
TmprtrFromDir = sdpvar(n_HeatBranch, n_T);  %正方向支路头结点温度
TmprtrToDir = sdpvar(n_HeatBranch, n_T);    %正方向支路尾结点温度
TmprtrFromRev = sdpvar(n_HeatBranch, n_T);  %逆方向支路头结点温度
TmprtrToRev = sdpvar(n_HeatBranch, n_T);    %逆方向支路尾结点温度

TmprtrBusDir = sdpvar(n_HeatBus,n_T);       %正方向系统各节点热水的温度
TmprtrBusRev = sdpvar(n_HeatBus,n_T);       %逆方向系统各节点热水的温度

HeatSource = sdpvar(n_HeatBus, n_T);        %热源供热，因为电炉和CHP连在同一个节点才写的这么诡异
HeatCHP = sdpvar(n_CHPgen,n_T);             %chp机组热出力
HeatEBoiler = sdpvar(n_EBoiler,n_T);        %电锅炉热出力
PowerEBoiler = sdpvar(n_EBoiler,n_T);       %电锅炉耗电

C = [];     %约束
% C = sdpvar(C)>=0;
SCUC_value = 0;

%%
%添加约束
%%
%火电机组开机费用
% Add_Huodian_Startup;
%%
%功率平衡
% Add_PowerBalance;
Add_PowerFlow;
%%
%爬坡约束
Add_Ramp;
%%
%最小启停时间限制
Add_MinUpDownTime;
%%
%火电机组出力
Add_Huodian_UnitOutput;
%%
%天然气网约束
Add_GasConstraints;
%%
%热网约束
Add_HeatConstraints;
%%
%火电二次费用函数
Add_Huodian_GenCost;
%%
%天然气费用
Add_Gas_Cost;
%%     
%配置 
ops = sdpsettings('solver','gurobi','verbose',2,'usex0',0);      
ops.gurobi.MIPGap = 1e-6;
ops.cplex.mip.tolerances.mipgap = 1e-6;

%%
%求解         
result = optimize(C, SCUC_value, ops);

if result.problem == 0 % problem =0 代表求解成功   
else
    error('求解出错');
end  
% plot([1: n_T], [sum(value(gen_P(:,:)))]);
plot([1: n_T], [value(gen_P(:,:))]);        %各机组出力
%%
%一些值的获取
gen_P = value(gen_P(:,:));
gen_P_upper = value(gen_P_upper);
PF_D = value(PF_D);
u_state = value(u_state(:,:));
gen_P_nl = value(gen_P_nl);
Va = value(Va);
obj_value = value(SCUC_value);
GasFlow = value(GasFlow);
GasPressure = sqrt(value(GasPressure2));
GasPressure2 = value(GasPressure2);
GasSourceOutput=value(GasSourceOutput);
GasGenNeed = value(GasGenNeed);

PowerEBoiler = value(PowerEBoiler);
TmprtrFromDir = value(TmprtrFromDir);  
TmprtrToDir = value(TmprtrToDir);    
TmprtrFromRev = value(TmprtrFromRev);  
TmprtrToRev = value(TmprtrToRev);    
TmprtrBusDir = value(TmprtrBusDir);       
TmprtrBusRev = value(TmprtrBusRev);       
HeatSource = value(HeatSource); 
HeatCHP = value(HeatCHP);             
HeatEBoiler = value(HeatEBoiler);     
GasCost = value(GasCost);
GasFlow2 = value(GasFlow2);
GasFlow2_nl = value(GasFlow2_nl);
GasFlowSymbol = value(GasFlowSymbol);
%检验
% MPC = mpc;
% MPC.gen(:, GEN_PG) = gen_P(: ,1)*baseMVA;
% MPC.bus(:, BUS_PD) = PD(:, 1)*baseMVA;
% test_result = rundcpf(MPC);
