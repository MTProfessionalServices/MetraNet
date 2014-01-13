
      select id_prod_view, id_view, dt_modified, nm_name, nm_table_name, b_can_resubmit_from from t_prod_view where lower(nm_name) = lower(N'%%NM_NAME%%')
			