GasCost = 0;
for t=1:n_T
    for i=1: n_GasSource
        GasCost=GasCost+GasSourceOutput(i,t)*GasSource(i,5);
    end
end 
SCUC_value = SCUC_value+GasCost;

