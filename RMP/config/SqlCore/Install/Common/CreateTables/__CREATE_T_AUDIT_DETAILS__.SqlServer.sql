
			CREATE TABLE t_audit_details (
			id_auditdetails int IDENTITY (1, 1) NOT NULL,
  			id_audit int NOT NULL,
 			tx_details nvarchar (4000) NULL,
			
			CONSTRAINT PK_t_auditdetails PRIMARY KEY CLUSTERED (id_auditdetails)
			)
		