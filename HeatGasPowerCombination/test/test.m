addpath('../functions');
addpath('../');
fff=4+n_branch;
for j = 1: n_branch
    BODF(j,:) = makeBODF(fff-n_branch, j, mpc);
end

temp = Bbus;
temp(1,:)=[];
temp(:,1)=[];
X=inv(temp);
tap = ones(n_branch, 1);								%% default tap ratio = 1
i = find(branch(:, BR_RATIO));						%% indices of non-zero tap ratios
tap(i) = branch(i, BR_RATIO);
for j = 1: n_branch
    for i = 2: n_bus
        m=branch(j,F_BUS)-1;
        n=branch(j,T_BUS)-1;
        if (m~=0&&n~=0)
            GSDF(j,i)=(X(m,i-1)-X(n,i-1))/branch(j,BR_X)/tap(j);
        elseif(m==0&&n~=0)
            GSDF(j,i)=(0-X(n,i-1))/branch(j,BR_X)/tap(j);
        elseif(m~=0&&n==0)
            GSDF(j,i)=(X(m,i-1)-0)/branch(j,BR_X)/tap(j);
        elseif(m==0&&n==0)
            GSDF(j,i)=0;
        else
        end
    end
end

GSDF=full(GSDF);
dp=zeros(n_bus,1);
dp([29 30]) = -[0.0300642268000000;0.132777556800000];
temp1 = PF_D(:,1)-GSDF*dp;
temp2 = BODF*Pm2all*temp1;
temp3 = BODF*PF_D(:,1);

MPC=mpc;
MPC.gen(:,GEN_PG)=gen_P(:,1)*baseMVA;
[MPC.branch, MPC.bus]=GetFault(MPC.branch, MPC.bus, MPC.gen, fff);
MPC.bus(:,BUS_PD)=PD(:,1)*baseMVA;
result_test1 = rundcpf(MPC);


MPC=mpc;
MPC.gen(:,GEN_PG)=gen_P(:,1)*baseMVA;
MPC.bus(:,BUS_PD)=PD(:,1)*baseMVA;
MPC.bus([29 30],BUS_PD) = 0;
result_test2 = rundcpf(MPC);

temp = zeros(n_bus, 1);
temp(gen(:,GEN_BUS)) = gen_P(:,1);
DC_BODF1 = makeDC_BODF_new(mpc, fff-n_branch, temp, PD(:,1));
DC_BODF2 = makeDC_BODF_test(mpc, fff-n_branch);
temp4 = DC_BODF1*PF_D(:,1);
temp5 = DC_BODF2*PF_D(:,1);

[temp5*100-result_test1.branch(:,14)]'
[temp3*100-result_test1.branch(:,14)]'
% result_test3 = rundcpf(mpc);
% temp5 = DC_BODF2*result_test3.branch(:,14);

%%
%ÏßÂ·
fb=10;
MPC=mpc;
MPC.gen(:,GEN_PG)=gen_P(:,1)*baseMVA;
[MPC.branch, MPC.bus] = GetFault(MPC.branch, MPC.bus, MPC.gen, fb);
MPC.bus(:,BUS_PD)=PD(:,1)*baseMVA;
result_test4 = rundcpf(MPC);

DC_LODF = makeDC_LODF_test(mpc, fb);
temp6 = DC_LODF*Pm2all*PF_D(:,1);
[temp6*100-result_test4.branch(:,14)]'