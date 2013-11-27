
	/* returns only a list of hard closed account/intervals (violations) */
	select aui.id_acc as column_value, aui.id_usage_interval from t_acc_usage_interval  aui
  where 
	aui.id_acc in (%%ACCOUNT_ID_LIST%%)
	and aui.id_usage_interval in (%%INTERVAL_ID_LIST%%) and aui.tx_status = 'H'
