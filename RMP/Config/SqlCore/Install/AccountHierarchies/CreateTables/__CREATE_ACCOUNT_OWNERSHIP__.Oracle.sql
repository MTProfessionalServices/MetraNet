
				create table t_acc_ownership
		        (id_owner number(10) NOT NULL, 
		        id_owned number(10) NOT NULL, 
		        id_relation_type number(10) NOT NULL, 
		        n_percent number(10) NOT NULL, 
						vt_start DATE NOT NULL,
						vt_end DATE NOT NULL, 
						tt_start TIMESTAMP NOT NULL,
						tt_end TIMESTAMP NOT NULL,
						constraint t_acc_ownership_PK PRIMARY KEY (id_owner, id_owned, id_relation_type, n_percent, vt_start, vt_end, tt_start, tt_end),
						CONSTRAINT t_acc_ownership_check1 CHECK (id_owner <> id_owned),
						CONSTRAINT t_acc_ownership_check2 CHECK (n_percent <= 100 AND n_percent >= 0),
						CONSTRAINT t_acc_ownership_check3 CHECK (vt_start <= vt_end),
						CONSTRAINT t_acc_ownership_check4 CHECK (tt_start <= tt_end))
        