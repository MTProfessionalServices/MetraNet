
			create table t_gsubmember (
			id_group int not null,
			id_acc int not null,
			vt_start datetime not null,
			vt_end datetime not null,
			CONSTRAINT date_gsubmember_check1 check ( vt_start <= vt_end)
			)
			