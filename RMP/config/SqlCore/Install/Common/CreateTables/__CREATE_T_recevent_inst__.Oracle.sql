
					create global temporary table tmp_recevent_inst
					(
							id_event INT NOT NULL,
							id_arg_interval INT,
							id_arg_billgroup INT,
							id_arg_root_billgroup INT
						)
					on commit delete rows
        