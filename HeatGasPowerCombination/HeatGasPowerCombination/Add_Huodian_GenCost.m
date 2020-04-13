%%
%这些机组组合约束也可以写在一个脚本里调用 方便
%发电机费用曲线 二次函数分段线性化
gen_P_nl = sdpvar(n_gen, n_L, n_T);
for i = 1: n_gen
    if (gen(i,GEN_TYPE)==HUODIAN)       %只加入火电机组的二次费用，其他种类另处理
        for t = 1: n_T
            C = [C,
                gen_P(i,t) == sum(gen_P_nl(i,:,t))+gen(i,GEN_PMIN)*u_state(i,t)/baseMVA,
                ];
            for l = 1: n_L
                C = [C,
                    0 <= gen_P_nl(i,l,t) <= (gen(i, GEN_PMAX)-gen(i, GEN_PMIN))/n_L/baseMVA,
                    ];
            end
        end
    end
end

%%
%发电机成本函数，仅考虑2次函数  如果多次要重写
% 二次函数形式，收敛较慢，我想既然二阶锥约束已经去掉了，不如把目标函数也分段线性化，整个问题是MILP，求解起来确实快一些
% opf_value = sum(gencost(:, GENCOST_C2)'*(gen_P(gen(:, GEN_BUS),:)*baseMVA).^2) + ...
%             sum(gencost(:, GENCOST_C1)'* gen_P(gen(:, GEN_BUS),:)*baseMVA) + ...
%             sum(gencost(:, GENCOST_C0)'*u_state(gen(:, GEN_BUS),:)) + ...
%             sum(sum(cost_up));
% 目标函数分段线性化
for i = 1: n_gen
    if (gen(i,GEN_TYPE)==HUODIAN)       %只加入火电机组的二次费用，其他种类另处理
        for t = 1: n_T
            SCUC_value = SCUC_value + A_gen(i)*u_state(i,t);
            for l = 1: n_L
                if (~isnan(Fij(i,l)))
                    SCUC_value = SCUC_value + Fij(i,l)*gen_P_nl(i,l,t)*baseMVA;
                end
            end
        end
    end
end



