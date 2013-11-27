
  CREATE GLOBAL TEMPORARY TABLE GLOBAL_DEPS
  (
    id_orig_event number(10) NOT NULL,
    tx_orig_billgroup_support VARCHAR2(15),
    id_orig_instance number(10) NOT NULL,
    id_orig_billgroup number(10),
    tx_orig_name VARCHAR2(255) NOT NULL, 
    tx_name nvarchar2(255) NOT NULL,     
    id_event number(10) NOT NULL,
    tx_billgroup_support VARCHAR2(15), 
    id_instance number(10),
    id_billgroup number(10),
    id_arg_interval number(10),
    dt_arg_start DATE,
    dt_arg_end DATE,
    tx_status VARCHAR2(14),
    b_critical_dependency VARCHAR2(1)
  ) ON COMMIT PRESERVE ROWS
		 