
			create table t_gsubmember (
			id_group NUMBER(10) not null,
			id_acc NUMBER(10) not null,
			vt_start date not null,
			vt_end date not null,
			CONSTRAINT date_gsubmember_check1 check ( vt_start <= vt_end)
			)
			