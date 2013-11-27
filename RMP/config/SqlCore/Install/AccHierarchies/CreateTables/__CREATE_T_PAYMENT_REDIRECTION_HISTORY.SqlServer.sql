
				create table t_payment_redir_history (
				id_payer int not null,
				id_payee int not null,
				vt_start datetime not null,
				vt_end datetime not null,
				tt_start datetime not null,
				tt_end datetime not null,
				CONSTRAINT date_redir_hist_check1 check ( vt_start <= vt_end)
				)
				