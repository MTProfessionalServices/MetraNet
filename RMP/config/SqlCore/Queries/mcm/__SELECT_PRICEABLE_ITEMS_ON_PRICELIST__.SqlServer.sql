           
				select rs.id_pi_template as id_pi_template,
				pit.id_template_parent as id_pi_template_parent,
				bp2.nm_display_name as PiDisplayName,
				bp2.nm_name as PiName, bp2.n_kind as PiKind, rs.id_pt as id_pt, bp1.nm_display_name as PtDisplayName, 
				bp1.nm_name as PtName 
				from t_rsched rs 
				join t_base_props bp1 on rs.id_pt=bp1.id_prop 
				join t_base_props bp2 on rs.id_pi_template=bp2.id_prop
				join t_pi_template pit on rs.id_pi_template=pit.id_template
				where rs.id_pricelist=%%ID_PRICELIST%% 
				group by  rs.id_pi_template, pit.id_template_parent, 
				bp2.nm_display_name, bp2.nm_name, bp2.n_kind, 
				rs.id_pt, bp1.nm_display_name, bp1.nm_name 
				order by pit.id_template_parent desc, id_pi_template, id_pt
 			