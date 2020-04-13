%%
% 机组开机费用 Cjk
cost_up = sdpvar(n_gen, n_T);
C = [C, cost_up >= 0];
for k = 1: n_T
    for t = 1: k-1
         C = [C,
            cost_up(:,k) >= start_cost(:,t).*(u_state(:,k) - sum(u_state(:,[k-t: k-1]),2))
            ];       
    end
end
for i = 1: n_gen
    if (init_state(i) == 0)
        C = [C,
            cost_up(i,1) >= start_cost(i,init_down(i))*(u_state(i,1)-init_down(i)*init_state(i))
            ];
    end
end
for k = 2: n_T
    for i = 1: n_gen
        if (init_state(i) == 0)
        C = [C,
            cost_up(i,k) >= start_cost(i,k+init_down(i)-1)*(u_state(i,k)-sum(u_state(i,[1: k-1]))-init_down(i)*init_state(i))
            ];
        end
    end
end
% C = [C,
%     cost_up(:,1) >= gencost(:,GENCOST_START).*(u_state(:,1)-init_state(:,)),
%     ];
% for k = 2: n_T
%     C = [C,
%         cost_up(:,k) >= gencost(:,GENCOST_START).*(u_state(:,k)-u_state(:,k-1)),
%         ];
% end

SCUC_value = SCUC_value + sum(sum(cost_up));
