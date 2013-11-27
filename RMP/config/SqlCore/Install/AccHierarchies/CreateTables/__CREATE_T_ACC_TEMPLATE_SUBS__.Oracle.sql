
				create table t_acc_template_subs (
				id_po number(10) null,
				id_group number(10) null,
				id_acc_template number(10) not null,
				vt_start date null,
				vt_end date null,
				CONSTRAINT t_acc_template_subs_check1 CHECK ((id_po IS NULL AND id_group IS NOT NULL) OR (id_po IS NOT NULL AND id_group IS NULL)),
				CONSTRAINT date_acc_template_check1 check ( vt_start <= vt_end)
				)
				