UPDATE %%TABLE_NAME%% RR 
SET RR.tx_state = 'N' 
WHERE EXISTS (SELECT id_sess FROM t_pv_AccountCredit AC WHERE RR.id_sess = AC.id_sess AND AC.c_IssueCreditNote = 1 ) 
AND NOT EXISTS (SELECT id_sess FROM t_acc_usage_interval AUI WHERE RR.id_interval = AUI.id_usage_interval AND RR.id_payer = AUI.id_acc AND AUI.tx_status = 'H') -- exclude hard-closed intervals


			