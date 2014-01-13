
			create table t_gsubmember_historical (
			id_group int not null,
			id_acc int not null,
			vt_start datetime not null,
			vt_end datetime not null,
			tt_start datetime not null,
			tt_end datetime not null,
			CONSTRAINT date_gsubmember_hist_check1 check ( vt_start <= vt_end)
			)
			