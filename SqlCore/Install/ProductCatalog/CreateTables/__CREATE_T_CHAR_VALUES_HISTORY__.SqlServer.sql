
        	CREATE TABLE t_char_values_history
          (
	          id_scv int NOT NULL,
	          id_entity int NOT NULL,
	          nm_value nvarchar(255) NULL,
	          c_start_date datetime NOT NULL,
	          c_end_date datetime NULL,
	          c_spec_name nvarchar(20) NOT NULL,
	          c_spec_type int NOT NULL
            )
         