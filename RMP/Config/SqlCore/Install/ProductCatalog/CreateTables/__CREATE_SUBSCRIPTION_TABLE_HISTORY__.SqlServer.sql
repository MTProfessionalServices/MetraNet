
			create table t_sub_history (
			id_sub int,
			id_sub_ext varbinary(16) not null,
			id_acc int null,
			id_po int not null,
			dt_crt datetime not null,
			id_group int null,
			vt_start datetime not null,
			vt_end datetime not null,
			tt_start datetime not null,
			tt_end datetime not null,
      		tx_quoting_batch varbinary(16) NULL,
			CONSTRAINT date_sub_hist_check1 check ( vt_start <= vt_end)
			)
				CREATE CLUSTERED INDEX idx_t_sub_history ON t_sub_history (id_sub,tt_end)
			