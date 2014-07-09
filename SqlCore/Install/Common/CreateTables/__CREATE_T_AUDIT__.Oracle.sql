    begin
        execute immediate
       'CREATE TABLE t_audit (
            id_audit number(10) NOT NULL,
            id_Event number(10),
            id_UserId number(10),
            id_entitytype number(10),
            id_entity number(10),
            tx_logged_in_as nvarchar2(50),
				    tx_application_name nvarchar2(50),
            dt_crt date NOT NULL,
            CONSTRAINT PK_t_audit PRIMARY KEY  (id_audit)
            )
       ';
       execute immediate 'create index idx_t_audit_dt_crt on t_audit(dt_crt desc)';
    end;
      