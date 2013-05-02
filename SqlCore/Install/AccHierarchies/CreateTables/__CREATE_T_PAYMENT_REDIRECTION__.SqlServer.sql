
				create table t_payment_redirection (
				id_payer int not null,
				id_payee int not null,
				vt_start datetime not null,
				vt_end datetime not null,
				CONSTRAINT date_payment_check1 check ( vt_start <= vt_end)
				)
				