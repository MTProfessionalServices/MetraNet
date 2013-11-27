
          /* CR 13075 - do not get gsub name from t_acc_template_subs, but from t_group_sub */
				  select 
				  s.id_po, s.id_group, s.id_acc_template, 
				  (CASE WHEN p.id_prop IS NULL THEN 'Y' ELSE 'N' END AS b_group, 
				  s.vt_start, s.vt_end, gsub.tx_name as nm_groupsubname
					from t_acc_template_subs s
					left outer join t_base_props p ON s.id_po=p.id_prop
					/* get group sub info */
					left outer join t_group_sub gsub ON s.id_group = gsub.id_group
					where s.id_acc_Template=%%TEMPLATEID%%

					