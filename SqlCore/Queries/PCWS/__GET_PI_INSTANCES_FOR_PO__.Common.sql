
                select
                bp.n_kind PIKind,
                map.id_pi_instance ID,
                bp.nm_name Name,
                bp.nm_display_name DisplayName,
                bp.nm_desc Description,
                map.id_pi_type PITypeID,
                piTypeBP.nm_name PITypeName,
                map.id_pi_template PITemplateID,
                piTemplateBP.nm_name PITemplateName,
				map.id_pi_instance_parent ParentPIInstanceID, 
				case (select count(1) from t_pl_map where b_canICB = 'Y' and id_pi_instance = map.id_pi_instance)
				  when 0 then 'N'
				  else 'Y'
				end PICanICB
                from
                t_pl_map map
                inner join
                t_base_props bp on map.id_pi_instance = bp.id_prop
                inner join
                t_base_props piTypeBP on map.id_pi_type = piTypeBP.id_prop
                inner join
                t_base_props piTemplateBP on map.id_pi_template = piTemplateBP.id_prop
                where id_po = %%PO_ID%% and id_paramtable is NULL
                %%PARENT_SELECTION_CONDITION%%
                