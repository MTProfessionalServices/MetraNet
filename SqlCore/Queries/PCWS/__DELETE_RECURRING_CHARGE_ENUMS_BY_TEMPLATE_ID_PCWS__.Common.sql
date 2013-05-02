
        DELETE FROM 
          t_recur_enum 
        WHERE EXISTS 
          (SELECT * FROM t_pl_map pl WHERE pl.id_pi_instance=id_prop AND pl.id_pi_template=%%ID_PROP%% AND pl.id_paramtable IS NULL)
  