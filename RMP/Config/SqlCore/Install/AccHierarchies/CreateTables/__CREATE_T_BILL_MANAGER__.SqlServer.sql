
				CREATE TABLE t_bill_manager (
	      id_manager int NOT NULL,
	      id_acc int NOT NULL,
        CONSTRAINT billman_check1 CHECK (id_manager <> id_acc)
        )				
				