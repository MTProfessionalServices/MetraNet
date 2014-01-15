INSERT INTO t_acc_usage_quoting
(
			quote_id
		   ,id_sess
           ,tx_UID
           ,id_acc
           ,id_payee
           ,id_view
           ,id_usage_interval
           ,id_parent_sess
           ,id_prod
           ,id_svc
           ,dt_session
           ,amount
           ,am_currency
           ,dt_crt
           ,tx_batch
           ,tax_federal
           ,tax_state
           ,tax_county
           ,tax_local
           ,tax_other
           ,id_pi_instance
           ,id_pi_template
           ,id_se
           ,div_currency
           ,div_amount
           ,is_implied_tax
           ,tax_calculated
           ,tax_informational
)
SELECT
			%%QUOTE_ID%%
		   ,id_sess
           ,tx_UID
           ,id_acc
           ,id_payee
           ,id_view
           ,id_usage_interval
           ,id_parent_sess
           ,id_prod
           ,id_svc
           ,dt_session
           ,amount
           ,am_currency
           ,dt_crt
           ,tx_batch
           ,tax_federal
           ,tax_state
           ,tax_county
           ,tax_local
           ,tax_other
           ,id_pi_instance
           ,id_pi_template
           ,id_se
           ,div_currency
           ,div_amount
           ,is_implied_tax
           ,tax_calculated
           ,tax_informational
FROM 
	t_acc_usage au
WHERE 
	au.id_acc in (%%ACCOUNTS%%) 
	and au.id_usage_interval = %%USAGE_INTERVAL%% 
	and au.id_prod in (%%POS%%)	
	and au.tx_batch in (%%BATCHIDS%%)