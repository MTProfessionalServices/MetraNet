
            select  
              rs.id_sched       ID,
              rs.id_pricelist   PriceListID,
              rs.id_pt          ParameterTableID,
              rs.id_eff_date    EffectiveDate,
              effdate.id_eff_date Effective_Id,
              effdate.n_begintype Effective_BeginType,
              effdate.dt_start Effective_StartDate,
              effdate.n_beginoffset Effective_BeginOffset,
              effdate.n_endtype Effective_EndType,
              effdate.dt_end Effective_EndDate,
              effdate.n_endoffset Effective_EndOffSet,      
              bp.nm_desc        Description           
             from 
             t_pricelist pl
             inner join t_rsched rs on pl.id_pricelist = rs.id_pricelist
             inner join t_effectivedate effdate on rs.id_eff_date = effDate.id_eff_date
             inner join t_base_props bp on rs.id_sched = bp.id_prop
             where rs.id_pricelist = %%PRICELIST_ID%% and rs.id_pt = %%PT_ID%%
             and pl.n_type = 1

            select 
	            pt.id_sched ScheduleID, n_order  RateIndex %%COLUMNS%% 
            from  %%PT_NAME%% pt
            inner join t_rsched sched on pt.id_sched = sched.id_sched
            left outer join t_base_props bp on sched.id_sched = bp.id_prop
            where sched.id_pricelist = %%PRICELIST_ID%% and sched.id_pt = %%PT_ID%%
            and %%MT_TIME%% >= pt.tt_start and (%%MT_TIME%% <= pt.tt_end or pt.tt_end is NULL)
            order by pt.id_sched, n_order asc  


          