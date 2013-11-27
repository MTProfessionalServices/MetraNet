
			select atname.nm_name as ajtname, pitname.nm_name as pitname from t_adjustment_type ajt
      inner join t_base_props atname on atname.id_prop = ajt.id_prop
      inner join t_base_props pitname on pitname.id_prop = ajt.id_pi_type
      where %%%UPPER%%%(atname.nm_name) = %%%UPPER%%%('%%NAME%%')
      AND ajt.id_pi_type <> %%ID_PI_TYPE%%
			