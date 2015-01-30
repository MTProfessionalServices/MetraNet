
create /*MATERIALIZED view*/
or replace view 
t_vw_allrateschedules_po
/*BUILD IMMEDIATE REFRESH FAST ON COMMIT */
as
select
tmInner.id_po as id_po,
tmInner.id_paramtable as id_paramtable,
tmInner.id_pi_instance as id_pi_instance,
tmInner.id_pi_template as id_pi_template,
tmInner.id_sub as id_sub,
rschedInner.id_sched as id_sched,
rschedInner.dt_mod as dt_mod,
teInner.n_begintype as rs_begintype, 
teInner.n_beginoffset as rs_beginoffset,
/* teInner.dt_start as rs_beginbase, */
NVL(teInner.dt_start, TO_DATE('1970-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) as rs_beginbase,
teInner.n_endtype as rs_endtype,
teInner.n_endoffset as rs_endoffset,
/* teInner.dt_end as rs_endbase, */
NVL(teInner.dt_end, TO_DATE('2036-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')) as rs_endbase,
rschedInner.id_pricelist as id_pricelist,
tmInner.rowid "tmInnerrowid", rschedInner.rowid "rschedInnerrowid",teInner.rowid "teInnerrowid"
from  t_pl_map tmInner,t_rsched rschedInner,t_effectivedate teInner 
where 
 rschedInner.id_pricelist = tmInner.id_pricelist 
 AND rschedInner.id_pt =tmInner.id_paramtable 
 AND rschedInner.id_pi_template = tmInner.id_pi_template
 and teInner.id_eff_date = rschedInner.id_eff_date
  