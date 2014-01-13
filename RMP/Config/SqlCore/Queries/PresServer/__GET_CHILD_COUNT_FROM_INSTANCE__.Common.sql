
           SELECT COUNT(*) AS cnt 
           FROM
					 t_pl_map inst 
           INNER JOIN t_pi_template child on inst.id_pi_template=child.id_template_parent
           WHERE
           inst.id_paramtable IS NULL
           AND 
           inst.id_pi_instance = %%ID_PI_INSTANCE%%
        