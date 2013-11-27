
        select id_pi,id_parent,nm_servicedef,nm_productview from  t_pi 
        INNER JOIN t_base_props on t_base_props.id_prop = t_pi.id_pi where t_base_props.n_kind = %%KIND%%
      