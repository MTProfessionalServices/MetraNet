
			select cast(id_template as number(10,0)) as id_template, nm_name, 
            (case when tx_desc IS null then nm_display_name else 
            tx_desc end) nm_display_name,
            (case when RebillAdjustments.id_pi_template is not null then 'TRUE' else 'FALSE' end) supportsRebill
        from (select distinct 
	        (case when id_template_parent is not null then id_template_parent 
            else id_template end) id_template
        from t_adjustment adj
            inner join t_pi_template piTemplate on adj.id_pi_template = piTemplate.id_template
	    where id_pi_template is not null ) templates
	    left outer join
	    (
	    		select adj.id_pi_template 
          from t_adjustment adj inner join t_adjustment_type adj_type on adj.id_adjustment_type = adj_type.id_prop 
          where adj_type.n_adjustmentType = 4
  		) RebillAdjustments on templates.id_template = RebillAdjustments.id_pi_template
            inner join t_base_props bp on templates.id_template = bp.id_prop 
            left outer join t_description DisplayNameDesc on bp.n_display_name = 
	        DisplayNameDesc.id_desc and DisplayNameDesc.id_lang_code = %%LANG_ID%% 
			