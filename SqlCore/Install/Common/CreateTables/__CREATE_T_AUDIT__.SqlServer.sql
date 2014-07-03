
			CREATE TABLE t_audit (
				id_audit int NOT NULL,
				id_Event int NULL,
				id_UserId int NULL,
				id_entitytype int NULL,
				id_entity int NULL,
				tx_logged_in_as nvarchar (50) NULL,
				tx_application_name nvarchar (50) NULL,
				dt_crt datetime NOT NULL,
				CONSTRAINT PK_t_audit PRIMARY KEY CLUSTERED (id_audit)
				)
				
			CREATE INDEX idx_t_audit_dt_crt on t_audit(dt_crt desc)  
		