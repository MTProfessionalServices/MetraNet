
   SELECT
      bp.id_prop, 
	  bp.nm_name,
	  bp.nm_desc as nm_desc,
	  bp.nm_display_name as nm_display_name,	  
	  bp.n_display_name,	 
	  bp.n_kind,
      tp.id_pi as id_pi_type, 
	  tp.id_template_parent as id_pi_parent, 
	  CAST(NULL AS INT) as id_pi_template, 
	  CAST(NULL AS INT) as id_po,	  
	   bp.n_desc
    FROM t_base_props bp
	  JOIN t_pi_template tp ON (bp.id_prop = tp.id_template)	  
    WHERE bp.nm_name = '%%NAME%%'
    