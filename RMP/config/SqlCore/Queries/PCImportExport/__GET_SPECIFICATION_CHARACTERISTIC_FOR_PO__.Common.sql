
				SELECT tscv.* FROM t_spec_char_values tscv
				INNER JOIN t_spec_val_map tsvm ON tsvm.id_scv = tscv.id_scv
				WHERE tsvm.id_spec = %%SPEC_ID%%
			