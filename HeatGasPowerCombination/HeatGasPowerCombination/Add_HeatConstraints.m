HeatFlowInMatrix = zeros(n_HeatBus,n_HeatBranch);       %带流量的
HeatFlowInIncMatrix = zeros(n_HeatBranch,n_HeatBus);    %关联矩阵
for i=1:n_HeatBranch
    %Tobus
    HeatFlowInMatrix(HeatBranch(i,3),i) = 1*HeatBranch(i,4);
    HeatFlowInIncMatrix(i,HeatBranch(i,3)) = 1;
end
HeatFlowInBus = HeatFlowInMatrix*ones(n_HeatBranch,1);   %流入各个节点的水流量

HeatFlowOutMatrix = zeros(n_HeatBus,n_HeatBranch);       %带流量的
HeatFlowOutIncMatrix = zeros(n_HeatBranch,n_HeatBus);    %关联矩阵
for i=1:n_HeatBranch
    %Frombus
    HeatFlowOutMatrix(HeatBranch(i,2),i) = 1*HeatBranch(i,4);
    HeatFlowOutIncMatrix(i,HeatBranch(i,2)) = 1;
end
HeatFlowOutBus = HeatFlowOutMatrix*ones(n_HeatBranch,1);   %流出各个节点的水流量

%%
%正向
%各个节点的热水温度=所有尾端是该节点的支路尾端温度混合
for t = 1: n_T
    C = [C,
        HeatFlowInBus.*TmprtrBusDir(:,t)==HeatFlowInMatrix*TmprtrToDir(:,t),
        ];
end
%各个节点的热水温度=与之相连的支路首端温度
for t = 1: n_T
    C = [C,
        HeatFlowOutIncMatrix*TmprtrBusDir(:,t)==TmprtrFromDir(:,t),
        ];
end

%%
%逆向
%流入矩阵是正向时的流出矩阵，流出矩阵是正向时的流入矩阵
%各个节点的热水温度=所有尾端是该节点的支路尾端温度混合
for t = 1: n_T
    C = [C,
        HeatFlowOutBus.*TmprtrBusRev(:,t)==HeatFlowOutMatrix*TmprtrToRev(:,t),
        ];
end
%各个节点的热水温度=与之相连的支路首端温度
for t = 1: n_T
    C = [C,
        HeatFlowInIncMatrix*TmprtrBusRev(:,t)==TmprtrFromRev(:,t),
        ];
end

%%
%各节点热负荷约束
for i = 1: n_HeatBus
    for t = 1: n_T
        if (HeatBus(i,HEATBUS_TYPE)==LOAD)
            C = [C,
                HeatD(i,t) == Cp*HeatFlowInBus(i,1)*(TmprtrBusDir(i,t)-TmprtrBusRev(i,t)),
                ];
        elseif (HeatBus(i,HEATBUS_TYPE)==SOURCE)
            C = [C,
                HeatSource(i,t) == Cp*HeatFlowOutBus(i,1)*(TmprtrBusDir(i,t)-TmprtrBusRev(i,t)),
                ];
        end
    end
end
%%
%HeatSource和chp以及电锅炉之间的关系
SourceCHPgenIncMatrix = zeros(n_HeatBus,n_CHPgen);
SourceEBoilerIncMatrix = zeros(n_HeatBus,n_EBoiler);
for i = 1: n_CHPgen
    SourceCHPgenIncMatrix(CHPgen(i,1),i) = 1;
end
for i = 1: n_EBoiler
    SourceEBoilerIncMatrix(EBoiler(i,1),i) = 1;
end
for t = 1: n_T
    C = [C,
        HeatSource(:,t) == SourceCHPgenIncMatrix*HeatCHP(:,t)+SourceEBoilerIncMatrix*HeatEBoiler(:,t),
        ];
end

%%
%chp热出力
for i = 1:n_CHPgen
    [row, col] = find(gen(:,GEN_BUS)==CHPgen(i,2));
    for t = 1: n_T
        C = [C,
            HeatCHP(i,t)==2.58*gen_P(row,col)*baseMVA,
            ];
    end
end
%%
%电锅炉热出力
for i = 1: n_EBoiler
    row = EBoiler(i,2);
    for t = 1: n_T
        C = [C,
            0.85*PowerEBoiler(i,t)*baseMVA == HeatEBoiler(i,t),
            HeatEBoiler(i,t)>=0,
            ];
    end
end
%%
%各支路首位温度关系
coefficient = zeros(n_HeatBranch,1);
for i = 1: n_HeatBranch
%         coefficient(i) = exp(-HeatBranch(i,8)*HeatBranch(i,5)/4200/HeatBranch(i,4)*3600);
        coefficient(i) = exp(-HeatBranch(i,8)*HeatBranch(i,5)/Cp/HeatBranch(i,4)/1000000);
end
for t = 1: n_T
    for i = 1: n_HeatBranch
        C = [C,
            HeatBus(i,5) >= TmprtrToDir(i,t) >= HeatBus(i,4),
            HeatBus(i,5) >= TmprtrFromDir(i,t) >= HeatBus(i,4),
            HeatBus(i,7) >= TmprtrToRev(i,t) >= HeatBus(i,6),
            HeatBus(i,7) >= TmprtrFromRev(i,t) >= HeatBus(i,6),
            %不计损耗
%             TmprtrToRev(i,t) == TmprtrFromRev(i,t),
%             TmprtrToDir(i,t) == TmprtrFromDir(i,t),
            %计及损耗
            TmprtrToRev(i,t) == coefficient(i)*(TmprtrFromRev(i,t)-SituationTempreture(t))+SituationTempreture(t),
            TmprtrToDir(i,t) == coefficient(i)*(TmprtrFromDir(i,t)-SituationTempreture(t))+SituationTempreture(t),
            ];
    end
end

