
			    SELECT aj.*, 't_aj_' + substring(pv.nm_table_name,6,1000) AS ajtable FROM t_adjustment_transaction aj
          INNER JOIN t_adjustment_Type ajt ON ajt.id_prop = aj.id_aj_type
          INNER JOIN t_pi pit ON pit.id_pi = ajt.id_pi_type
          INNER JOIN t_prod_view pv ON %%%UPPER%%%(pv.nm_name) = %%%UPPER%%%(pit.nm_productview)
          INNER JOIN %%TABLE_NAME%% rs ON rs.id_sess = aj.id_sess
			