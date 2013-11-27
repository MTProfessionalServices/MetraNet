
			select
			id_payer,id_payee,vt_start,vt_end
			from t_payment_redirection
			where id_payer = %%ID_PAYER%% and
			%%REFDATE%% between vt_start AND vt_end
			