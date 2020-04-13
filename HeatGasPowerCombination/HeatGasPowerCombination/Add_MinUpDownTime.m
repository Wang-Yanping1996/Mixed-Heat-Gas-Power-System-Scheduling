%%
% 机组组合约束
%最小启动时间限制
for i = 1: n_gen
    Gi = min(n_T, (min_up(i)-init_up(i))*init_state(i));
    %分三段 起始，中间，结尾
    %起始时考虑初始状态的影响，中间不需考虑太多，结尾保证开了以后没关过
    if (Gi >= 1)
        C = [C,
            sum(u_state(i, [1: Gi])) == Gi,
            ];
    end
    for t = Gi+1: n_T-min_up(i)+1
        if (t > 1)
        C = [C,
            sum(u_state(i,[t: t+min_up(i)-1])) >= min_up(i).*(u_state(i,t)-u_state(i,t-1)),
            ];
        elseif (t == 1)
        C = [C,
            sum(u_state(i,[t: t+min_up(i)-1])) >= min_up(i).*(u_state(i,t)-init_state(i)),
            ];        
        else
        end
    end
    for t = n_T-min_up(i)+2: n_T
        if (t > 1)
            C = [C,
                sum(u_state(i,[t: n_T])) >= (n_T-t+1).*(u_state(i,t)-u_state(i,t-1)),
                ];
        elseif (t == 1)
            C = [C,
                sum(u_state(i,[t: n_T])) >= (n_T-t+1).*(u_state(i,t)-init_state(i)),
                ];            
        else
        end
    end
end
%%
% 机组组合约束
%最小关机时间限制 同最小开机时间限制
for i = 1: n_gen
    Li = min(n_T, (min_down(i)-init_down(i))*(1-init_state(i)));
    if (Li >= 1)
        C = [C,
            sum(u_state(i, [1: Li])) == 0,
            ];
    end
    for t = Li+1: n_T-min_down(i)+1
        if (t > 1)
        C = [C,
            sum(u_state(i, [t: t+min_down(i)-1])) <= min_down(i).*(1-u_state(i,t-1)+u_state(i,t)),
            ];
        elseif (t == 1)
        C = [C,
            sum(u_state(i, [t: t+min_down(i)-1])) <= min_down(i).*(1-init_state(i)+u_state(i,t)),
            ];
        else
        end
    end
    for t = n_T-min_down(i)+2: n_T
        if (t > 1)
        C = [C,
            sum(u_state(i,[t: n_T])) <= (n_T-t+1).*(1-u_state(i,t-1)+u_state(i,t)),
            ];
        elseif (t == 1)
        C = [C,
            sum(u_state(i,[t: n_T])) <= (n_T-t+1).*(1-init_state(i)+u_state(i,t)),
            ];
        else
        end            
    end
end
