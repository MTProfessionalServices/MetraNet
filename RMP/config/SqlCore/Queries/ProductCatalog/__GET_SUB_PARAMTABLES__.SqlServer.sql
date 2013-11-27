
				select
				sub.id_sub,
				map.id_po,map.id_pi_instance,map.id_paramtable, 
				instance_nm_name = case when tb_ip.id_prop is NULL then tb.nm_display_name else
				(select tb_ip.nm_display_name + '/' + tb.nm_display_name) end,
				tb_pt.nm_name pt_nm_name,
				tb_po.nm_name po_nm_name,
				tb_po.nm_display_name po_nm_display_name,
				b_PersonalRate = case when (select count(id_sub) from t_pl_map map2 where map2.id_pi_instance = map.id_pi_instance AND
				map2.id_paramtable = map.id_paramtable and map2.id_sub = sub.id_sub and map2.id_acc = %%ID_ACC%%) > 0 then 'Y' else 'N' end,
				map.b_canICB,
				sub.dt_start,sub.dt_end
				from t_base_props tb,t_base_props tb_pt,t_base_props tb_po,
				t_pi_template
				JOIN t_vw_effective_subs sub on sub.id_acc = %%ID_ACC%%
				JOIN t_pl_map map on map.id_po = sub.id_po
				LEFT OUTER JOIN t_base_props tb_ip on tb_ip.id_prop = map.id_pi_instance_parent
				where 
				map.id_sub is NULL AND map.id_paramtable is not null AND
				tb.id_prop =  map.id_pi_instance AND
				tb_pt.id_prop = map.id_paramtable AND
				tb_po.id_prop = map.id_po AND
				t_pi_template.id_template = map.id_pi_template AND
				((%%%SYSTEMDATE%%% between sub.dt_start AND sub.dt_end)
				OR %%%SYSTEMDATE%%% <= sub.dt_start)
			