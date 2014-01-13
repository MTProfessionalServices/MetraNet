
				create table t_payment_redirection (
				id_payer number(10) not null,
				id_payee number(10) not null,
				vt_start date not null,
				vt_end date not null,
				CONSTRAINT date_payment_check1 check ( vt_start <= vt_end)
				)
				