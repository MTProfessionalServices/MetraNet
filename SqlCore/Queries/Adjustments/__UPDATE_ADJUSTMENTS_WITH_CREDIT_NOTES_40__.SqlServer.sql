UPDATE RR 
SET RR.tx_state = 'N' 
FROM %%TABLE_NAME%% RR 
INNER JOIN t_pv_AccountCredit AC ON RR.id_sess = AC.id_sess AND AC.c_IssueCreditNote = 1
INNER JOIN t_acc_usage_interval AUI ON RR.id_interval = AUI.id_usage_interval AND RR.id_payer = AUI.id_acc AND AUI.tx_status <> 'H' -- exclude hard-closed intervals    


			