
				update t_payment_redirection set vt_start = {ts '%%STARTDATE%%'},
				vt_end = {ts '%%ENDDATE%%'}
				where id_payer = %%ID_PAYER%% AND id_payee = %%ID_PAYEE%% AND
				vt_start = {ts '%%ORIGINAL_START_DATE%%'} and
				vt_end = {ts '%%ORIGINAL_END_DATE%%'}
			