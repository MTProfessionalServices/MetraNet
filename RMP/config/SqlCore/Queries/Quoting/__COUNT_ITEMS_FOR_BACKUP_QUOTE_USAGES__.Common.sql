SELECT count (1) as num_charges
FROM 
	t_acc_usage au
WHERE 
	au.id_acc in (%%ACCOUNTS%%) 
	and au.id_usage_interval = %%USAGE_INTERVAL%% 
	and au.id_prod in (%%POS%%)	
	and au.tx_batch in (%%BATCHIDS%%)