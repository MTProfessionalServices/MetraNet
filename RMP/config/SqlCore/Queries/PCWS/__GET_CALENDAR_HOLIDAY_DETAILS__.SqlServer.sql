
				        select
                  rs.id_sched       ID,
                  rs.id_pricelist   PriceListID,
                  rs.id_pt          ParameterTableID,
                  rs.id_eff_date    EffectiveDate,
                  eff.n_begintype	BeginType,
                  eff.dt_start		Dt_Start,
                  eff.n_beginoffset BeginOffSet,
                  eff.n_endtype		EndType,
                  eff.dt_end		Dt_End,
                  eff.n_endoffset	EndOffSet,
                  bp.nm_desc        Description
                  from
                t_pl_map map
                  inner join t_rsched rs on map.id_pricelist = rs.id_pricelist and rs.id_pt = map.id_paramtable
                  inner join t_effectivedate eff on rs.id_eff_date = eff.id_eff_date
                  left outer join t_base_props bp on rs.id_sched = bp.id_prop
                where
                  map.id_pi_instance =  %%ID_PI_INSTANCE%%
                  and map.id_sub = %%ID_SUB%%
                  and rs.id_pt = %%ID_PT%%
                  order by ID asc

                select
                  pt.*
                from  %%PT_NAME%% pt
                  inner join t_rsched rs on pt.id_sched = rs.id_sched
                  inner join t_pl_map map on rs.id_pricelist = map.id_pricelist and rs.id_pt = map.id_paramtable
                  left outer join t_base_props bp on rs.id_sched = bp.id_prop
                where
                  map.id_pi_instance = %%ID_PI_INSTANCE%%
                  and map.id_sub = %%ID_SUB%%
                  and rs.id_pt = %%ID_PT%%
                  and current_timesteamp >= pt.tt_start and (current_timestamp <= pt.tt_end or pt.tt_end is NULL)
                  order by pt.id_sched, n_order asc
				