%% 
% 机组组合约束
%系统功率平衡约束
for t = 1: n_T
    C = [C,
        sum(gen_P(:,t)) >= sum(PD(:,t)),
        ];
end