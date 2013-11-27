
				create table t_impersonate (
				id_owner int not null,
				id_acc int not null,
				CONSTRAINT impersonate_check1 CHECK (id_owner <> id_acc)
				)
				