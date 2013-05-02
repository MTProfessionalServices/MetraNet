
    create or replace type deps_rec as object
    (
      id_orig_event INT,
      tx_orig_billgroup_support VARCHAR2(15),  /* useful for debugging */
      id_orig_instance INT,
      id_orig_billgroup INT,                  /* useful for debugging  */
      tx_orig_name VARCHAR2(255) , 		/* useful for debugging  */
      tx_name nvarchar2(255) ,         /* useful for debugging  */
      id_event INT ,
      tx_billgroup_support VARCHAR2(15),      /* useful for debugging  */
      id_instance INT,
      id_billgroup INT,                       /* useful for debugging  */
      id_arg_interval INT,
      dt_arg_start date,
      dt_arg_end date,
      tx_status VARCHAR2(14),
      b_critical_dependency VARCHAR2(1)
    )
       