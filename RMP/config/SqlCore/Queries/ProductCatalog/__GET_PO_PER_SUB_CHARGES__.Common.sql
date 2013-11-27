
			select r.id_prop, NULL id_acc, NULL vt_start, NULL vt_end, r.max_unit_value, r.min_unit_value, 
      r.nm_unit_name, r.b_charge_per_participant 
			from t_pl_map m 
      inner join t_recur r on m.id_pi_instance=r.id_prop
			where m.id_po=%%ID_PO%%
      and m.id_paramtable is null
      and r.b_charge_per_participant = 'N'  
		