%%
% 机组组合约束
%旋转备用约束
for t = 1: n_T
    C = [C,
        sum(gen_P_upper(:,t))+sum(Pmax_Shui)+sum(TeInput(:,t))-sum(Spinning(:,t))-sum(PD(:,t))>=0,  %这里sum(PmaxShui)似乎没必要
%         sum(PD(:,t))-sum(gen_P_lower(:,t))-sum(Pmin_Shui)-sum(TeInput(:,t)) >=0,                    %这个没看懂
        ];
end
