for i = 1: n_GasBranch
    for t = 1:n_T
            if ((sum(GasFlow_nl(i,t,:))-GasFlow(i,t)~=0)||(sum(state_GasFlow_nl(i,t,:))-1~=0))
                a = -inf;
            end
        for l = 1: n_L_w2
            if (state_GasFlow_nl(i,t,l)*GasFlow_interval(i,l)- GasFlow_nl(i,t,l) >0)||(GasFlow_nl(i,t,l) - state_GasFlow_nl(i,t,l)*GasFlow_interval(i,l+1) >0)
               a = -inf;
            end
        end
    end
end