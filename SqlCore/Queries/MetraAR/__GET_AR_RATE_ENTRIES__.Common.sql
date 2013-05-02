
          select 
	          pt.id_sched as "ScheduleID", 
	          n_order  as "RateIndex" 
	          %%COLUMNS%% 
          from  
	          %%PT_NAME%% pt
              inner join 
              t_rsched sched on pt.id_sched = sched.id_sched
              left outer join
              t_base_props bp on sched.id_sched = bp.id_prop
          where 
	          sched.id_pricelist = @pricelistId
	          and 
	          sched.id_pt = @ptId
	          and 
	          @sysTime >= pt.tt_start 
	          and 
	          (@sysTime <= pt.tt_end or pt.tt_end is NULL)
          order by 
	          "ScheduleID", 
	          "RateIndex" asc  
          