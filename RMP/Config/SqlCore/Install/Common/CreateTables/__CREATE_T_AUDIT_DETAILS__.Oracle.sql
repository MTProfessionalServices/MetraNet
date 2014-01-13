
      CREATE TABLE t_audit_details (
        id_auditdetails number(10) NOT NULL,
        id_audit number(10) NOT NULL,
        tx_details nvarchar2(2000) ,
        CONSTRAINT PK_t_auditdetails PRIMARY KEY  (id_auditdetails)
        )
      