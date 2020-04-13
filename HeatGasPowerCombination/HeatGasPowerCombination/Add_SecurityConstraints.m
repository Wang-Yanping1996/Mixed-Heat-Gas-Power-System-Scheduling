%%
%支路潮流约束
% 仅考虑有功约束
% -Pmax <=P <= Pmax
for i = 1: n_branch
    if (branch(i, RATE_A) ~= 0)     %rateA为0则认为不需要添加安全约束
        C = [C,
            -k_safe*branch(i, RATE_A)/baseMVA <= PF_D(i,:) <= k_safe*branch(i, RATE_A)/baseMVA
            ];
    end
end