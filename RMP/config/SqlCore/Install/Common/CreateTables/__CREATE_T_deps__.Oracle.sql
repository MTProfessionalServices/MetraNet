
create global temporary table tmp_deps
             (
                  id_orig_event INT NOT NULL,
									tx_orig_billgroup_support VARCHAR2(15),
                  id_orig_instance INT NOT NULL,
									id_orig_billgroup INT,
                  tx_orig_name VARCHAR2(255) NOT NULL, /* useful for debugging */
                  tx_name nvarchar2(255) NOT NULL,      /* useful for debugging */
                  id_event INT NOT NULL,
                  tx_billgroup_support VARCHAR2(15),
                  id_instance INT,
                  id_billgroup INT,
                  id_arg_interval INT,
                  dt_arg_start DATE,
                  dt_arg_end DATE,
                  tx_status VARCHAR2(14),
                  b_critical_dependency VARCHAR2(1)
             ) on commit preserve rows
        