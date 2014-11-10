
				create table t_acc_template_subs_pub (
				id_po int null,
				id_group int null,
				id_acc_template int not null,
				vt_start datetime null,
				vt_end datetime null,
				CONSTRAINT t_acc_template_subs_pub_1 CHECK ((id_po IS NULL AND id_group IS NOT NULL) OR (id_po IS NOT NULL AND id_group IS NULL)),
				CONSTRAINT date_acc_template_pub_1 check ( vt_start <= vt_end)
				)
				