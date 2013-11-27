
        create global temporary table tmp_instances
                 (
                    id_event INT NOT NULL,
                    tx_type VARCHAR2(11) NOT NULL,
                    tx_name nvarchar2(255) NOT NULL,
                    id_instance INT NOT NULL,
                    id_arg_interval INT,
                    id_arg_billgroup INT,
										id_arg_root_billgroup INT,
                    dt_arg_start DATE,
                    dt_arg_end DATE
                 ) on commit delete rows
        