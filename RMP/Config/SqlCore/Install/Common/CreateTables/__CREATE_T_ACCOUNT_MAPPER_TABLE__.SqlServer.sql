
			     CREATE TABLE t_account_mapper (nm_login nvarchar(255) NOT
				 NULL, nm_space nvarchar(40) NOT NULL, id_acc int NOT
				 NULL,CONSTRAINT PK_t_account_mapper PRIMARY KEY CLUSTERED (
				 nm_login, nm_space))
			 