
delete from t_account_view_prop
where id_account_view in (
	select id_account_view from t_account_view_log
	where lower(nm_account_view) = N'%%AV_NAME%%')
			