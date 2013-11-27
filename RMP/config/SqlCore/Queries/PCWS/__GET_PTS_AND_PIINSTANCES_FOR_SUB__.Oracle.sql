
			  BEGIN
			  
			  open :1 for
			  select id_sub from t_sub where id_sub = %%ID_SUB%%;

			  open :2 for
			  select
				id_pi_instance PIID,
				pi_bp.nm_name PIName,
				id_paramtable PTID,
				pt_bp.nm_name PTName,
				b_CanIcb CanICB,
				case when
					(select count(id_sub) from t_pl_map map2 where map2.id_pi_instance = map.id_pi_instance AND
						map2.id_paramtable = map.id_paramtable and map2.id_sub = %%ID_SUB%%) > 0 then
					'Y'
				else
					'N'
				end as b_PersonalRate
			  from 
				t_sub sub
				inner join t_pl_map map on sub.id_po = map.id_po
				inner join t_base_props pi_bp on map.id_pi_instance = pi_bp.id_prop
				inner join t_base_props pt_bp on map.id_paramtable = pt_bp.id_prop
			  where 
				sub.id_sub = %%ID_SUB%% 
				and id_paramtable is not null
				and map.id_sub is null
			  order by id_pi_instance, id_paramtable;
			  
			  open :3 for
			  select
			  id_pi_instance,
			  id_paramtable,
			  instDesc.id_lang_code InstanceLangCode,
			  instDesc.nm_display_name InstanceDisplayname,
			  ptDesc.id_lang_code PTLangCode,
			  ptDesc.nm_display_name ptDisplayName
			  from
			  t_sub sub
			  inner join
			  t_pl_map map on sub.id_po = map.id_po
			  left outer join
			  t_vw_base_props instDesc on map.id_pi_instance = instDesc.id_prop
			  left outer join
			  t_vw_base_props ptDesc on map.id_paramtable = ptDesc.id_prop and instDesc.id_lang_code = ptDesc.id_lang_code
			  where
			  (ptdesc.nm_desc is not null or instDesc.nm_desc is not null)
			  and
			  sub.id_sub = %%ID_SUB%%
			  and
			  id_paramtable is not null
			  and map.id_sub is null
			  order by id_pi_instance, id_paramtable;
			 END;
			 