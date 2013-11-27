
					create table t_impersonate (
					id_owner NUMBER(10) not null,
					id_acc NUMBER(10) not null,
					CONSTRAINT impersonate_check1 CHECK (id_owner <> id_acc)
					)
				