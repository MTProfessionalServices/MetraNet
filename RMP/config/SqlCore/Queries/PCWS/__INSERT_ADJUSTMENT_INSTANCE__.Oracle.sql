
			  insert into t_adjustment(id_prop, tx_guid, id_pi_instance, id_adjustment_type)
				select
					%%ID_PROP%%,
					rawtohex(hextoraw(replace('%%GUID%%','0x',''))),
					%%PI_ID%%,
					id_prop
				from
					t_base_props
				where
					nm_name = '%%ADJ_NAME%%'
					and
					n_kind = 320
			