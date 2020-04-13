%%
%火电发电机有功出力约束
for  t = 1: n_T
    for i = 1: n_gen
%         if (gen(i,GEN_TYPE)==HUODIAN)
            C = [C,
                gen_P_upper(i,t) >= gen_P(i,t) >= u_state(i,t).*gen(i, GEN_PMIN)/baseMVA,
                u_state(i,t).*gen(i, GEN_PMAX)/baseMVA  >= gen_P_upper(i,t) >= 0
                ];
%         else
%             C = [C,
%                 gen_P(i,t)>=0
%                 ];
%         end
    end
end
