
			create table t_gsubmember_historical (
			id_group NUMBER(10) not null,
			id_acc NUMBER(10) not null,
			vt_start date not null,
			vt_end date not null,
			tt_start date not null,
			tt_end date not null,
			CONSTRAINT date_gsubmember_hist_check1 check ( vt_start <= vt_end)
			)
			