UPDATE t_acc_usage_quoting 
SET 
	quote_id = %%NEW_QUOTE_ID%%
WHERE 
	quote_id = %%QUOTE_ID%%