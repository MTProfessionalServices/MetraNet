
				create table t_acc_ownership
		        (id_owner INT NOT NULL, 
		        id_owned INT NOT NULL, 
		        id_relation_type INT NOT NULL, 
		        n_percent INT NOT NULL, 
				vt_start DATETIME NOT NULL,
				vt_end DATETIME NOT NULL, 
				tt_start DATETIME NOT NULL,
				tt_end DATETIME NOT NULL,
				constraint t_acc_ownership_PK PRIMARY KEY (id_owner, id_owned, id_relation_type, n_percent, vt_start, vt_end, tt_start, tt_end))
				alter table t_acc_ownership add CONSTRAINT t_acc_ownership_check1 CHECK (id_owner <> id_owned)
				alter table t_acc_ownership add CONSTRAINT t_acc_ownership_check2 CHECK (n_percent <= 100 AND n_percent >= 0)
				alter table t_acc_ownership add CONSTRAINT t_acc_ownership_check3 CHECK (vt_start <= vt_end)
				alter table t_acc_ownership add CONSTRAINT t_acc_ownership_check4 CHECK (tt_start <= tt_end)
        