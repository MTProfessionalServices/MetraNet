
select *
/*  __CHECK_RECUR_VALUE_CONTIGUOUS_HISTORY__ */
/*  Find "holes" in the history.  A hole in history will be */
/*  a pair of intervals for which there is no third interval */
/*  that "extends" either of them toward the other. */
/*  We only check this for the "currently valid state" because */
/*  we assume that all records were checked when they were inserted. */
from   t_recur_value rv1 
inner join t_recur_value rv2 
	on rv1.id_prop = rv2.id_prop 
	and rv1.id_sub = rv2.id_sub 
	and dbo.addsecond(rv1.vt_end) < rv2.vt_start
where  rv1.tt_end = dbo.mtmaxdate()
   and rv2.tt_end = dbo.mtmaxdate()
   and not exists(
         select 1
         from   t_recur_value rv3
         where  rv3.id_prop = rv1.id_prop
	         and rv3.id_sub = rv3.id_sub
	         and rv3.tt_end = dbo.mtmaxdate()
	         and((rv3.vt_start <= dbo.addsecond(rv1.vt_end)
	              and rv3.vt_end > rv1.vt_end
	             )
	             or(rv3.vt_start < rv2.vt_start
	                and dbo.addsecond(rv3.vt_end) >= rv2.vt_start
	               )
	            ))
		