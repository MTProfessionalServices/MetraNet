
        	CREATE TABLE t_char_values_history
          (
	          id_scv int NOT NULL,
	          id_entity int NOT NULL,
	          nm_value nvarchar2(255) NULL,
	          c_start_date timestamp NOT NULL,
	          c_end_date timestamp NULL,
	          c_spec_name nvarchar2(20) NOT NULL,
	          c_spec_type int NOT NULL
            )
         