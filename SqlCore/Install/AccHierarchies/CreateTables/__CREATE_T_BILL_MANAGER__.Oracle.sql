
					create table t_bill_manager (
					id_manager NUMBER(10) not null,
					id_acc NUMBER(10) not null,
					CONSTRAINT billman_check1 CHECK (id_manager <> id_acc)
					)
				