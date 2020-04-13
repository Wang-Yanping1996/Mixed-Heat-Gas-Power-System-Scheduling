%气网中气压与流量的分段函数
GasFlow2 = sdpvar(n_GasBranch,n_T);         %GasFlow的平方
GasFlowSymbol = binvar(n_GasBranch,n_T,2);    %标志流向的二进制变量
n_L_w2 = 20;   %w2流量平方的分段函数 100太大了
state_GasFlow2_nl = binvar(n_GasBranch,n_T,n_L_w2);
GasFlow2_nl = sdpvar(n_GasBranch,n_T,n_L_w2);
GasFlow2Max = zeros(n_GasBranch,1);
Cij=GasBranch(:,4);
for i = 1: n_GasBranch
    f_bus = GasBranch(i,2);
    t_bus = GasBranch(i,3);
    GasFlow2Max(i) = max(Cij(i)^2*abs(GasBus(f_bus,2)^2-GasBus(t_bus,3)^2), Cij(i)^2*abs(GasBus(f_bus,3)^2-GasBus(t_bus,2)^2));
    GasFlow2Max(i) = min(GasFlow2Max(i),4);     %数据里的上界太离谱了，范围不准没法近似
end
%一些必要的参数
GasFlow2_interval = zeros(n_GasBranch, n_L_w2+1);           %每个区间上下界
GasFlow2_low = zeros(n_GasBranch, n_L_w2);                  %每个区间左端点的函数值 
for i = 1: n_GasBranch
    GasFlow2_interval(i, :) = 0: GasFlow2Max(i)/n_L_w2: GasFlow2Max(i);   %已经是实际值了
    for l = 1: n_L_w2
        GasFlow2_low(i,l) = sqrt(GasFlow2_interval(i,l));
    end
end
%各段斜率
Fij_GasFlow2 = zeros(n_GasBranch, n_L_w2);
for i = 1: n_GasBranch
    for l = 1: n_L_w2
        Fij_GasFlow2(i, l) = (sqrt(GasFlow2_interval(i,l+1))-sqrt(GasFlow2_interval(i,l)))/(GasFlow2_interval(i,l+1)-GasFlow2_interval(i,l));
    end
end

%%
%GasFlow2分段
for i = 1: n_GasBranch
    for t = 1:n_T
        C = [C,
            sum(GasFlow2_nl(i,t,:))==GasFlow2(i,t),
            sum(state_GasFlow2_nl(i,t,:))==1,
            -sqrt(GasFlow2Max(i))<=GasFlow(i,t)<=sqrt(GasFlow2Max(i)),
            ];
        for l = 1: n_L_w2
            C = [C,
                state_GasFlow2_nl(i,t,l)*GasFlow2_interval(i,l)<= GasFlow2_nl(i,t,l) <= state_GasFlow2_nl(i,t,l)*GasFlow2_interval(i,l+1),
                0 <= GasFlow2_nl(i,t,l) <= GasFlow2_interval(i,l+1)
                ];
        end
    end
end

for t = 1: n_T
    for i = 1: n_GasBranch
        GasFlow_temp = 0;
        for l = 1: n_L_w2
            GasFlow_temp = GasFlow_temp+...
                        state_GasFlow2_nl(i,t,l)*GasFlow2_low(i,l)+(GasFlow2_nl(i,t,l)-state_GasFlow2_nl(i,t,l)*GasFlow2_interval(i,l))*Fij_GasFlow2(i, l);
        end
%         C = [C,
%             abs(GasFlow(i,t)) == GasFlow_temp,
%             ];
        %流量方向
        f_bus = GasBranch(i,2);
        t_bus = GasBranch(i,3);
        C = [C,
            GasFlowSymbol(i,t,1)+GasFlowSymbol(i,t,2)==1,
            implies(GasFlowSymbol(i,t,1),[GasPressure2(f_bus,t)>=GasPressure2(t_bus,t),GasFlow(i,t)==GasFlow_temp]),
            implies(GasFlowSymbol(i,t,2),[GasPressure2(f_bus,t)<=GasPressure2(t_bus,t),GasFlow(i,t)==-GasFlow_temp]),
            ];
    end
end

%%
%wij = Cij*根号下(fai-fai)
for i = 1: n_GasBranch
    f_bus = GasBranch(i,2);
    t_bus = GasBranch(i,3);
    for t = 1: n_T
        C = [C,
            GasFlow2(i,t) == Cij(i)^2*abs(GasPressure2(f_bus,t)-GasPressure2(t_bus,t)),
            ];
    end
end

%%
%节点气压限制
for i = 1: n_GasBus
    for t = 1: n_T
        C = [C,
            GasBus(i,3)^2<=GasPressure2(i,t)<=GasBus(i,2)^2
            ];
    end
end





