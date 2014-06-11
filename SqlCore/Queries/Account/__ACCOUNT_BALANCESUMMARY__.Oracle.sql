/* For a given account, what balance information we want to show on Account 360*/
SELECT  current_balance AS CurrentBalance,
		invoice_currency as CurrentBalanceCurrency, 
		balance_forward_date AS CurrentBalanceDate 
FROM t_invoice
WHERE id_payer = %%ACCOUNT_ID%% 
		AND balance_forward_date = ( SELECT MAX(balance_forward_date) FROM t_invoice WHERE id_payer = %%ACCOUNT_ID%%)
		AND rownum = 1