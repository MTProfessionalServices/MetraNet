
             select distinct
              rs.id_sched          ID,
              rs.id_pricelist       PriceListID,
              rs.id_pt                  ParameterTableID,
              rs.id_eff_date      EffectiveDate,
              bp.nm_desc        Description
             from
              t_rsched rs
              inner join t_pl_map map on map.id_pricelist = rs.id_pricelist 
				and rs.id_pt = map.id_paramtable and rs.id_pi_template = map.id_pi_template 
              left outer join t_base_props bp on rs.id_sched = bp.id_prop
			 where
			  map.id_pi_instance = %%ID_PI%%
			  and
			  map.id_pi_template = %%ID_TMPL%%
			  and
			  map.id_po = %%ID_PO%%
			  and
			  rs.id_pt = %%ID_PT%%
			 order by ID asc
		  