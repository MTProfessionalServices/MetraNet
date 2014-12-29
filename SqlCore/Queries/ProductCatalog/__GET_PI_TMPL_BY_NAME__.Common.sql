
   SELECT
      bp.id_prop, 
	  bp.nm_name,
	  COALESCE(vbp.nm_desc, bp.nm_desc) as nm_desc,
	  COALESCE(vbp.nm_display_name, bp.nm_display_name) as nm_display_name,	  
	  bp.n_display_name,	 
	  vbp.n_kind,
      tp.id_pi as id_pi_type, 
	  tp.id_template_parent as id_pi_parent, 
	  CAST(NULL AS INT) as id_pi_template, 
	  CAST(NULL AS INT) as id_po,	  
	   bp.n_desc
    FROM t_base_props bp
	  JOIN t_pi_template tp ON (bp.id_prop = tp.id_template)
	  LEFT OUTER JOIN t_vw_base_props vbp ON (bp.id_prop = vbp.id_prop and vbp.id_lang_code = %%ID_LANG%%)
    WHERE bp.nm_name = '%%NAME%%'
    