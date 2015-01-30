
create /*MATERIALIZED view*/ or replace view t_vw_allrateschedules_po_noicb
(
id_po, 
id_paramtable, 
id_pi_instance,
id_pi_template,
id_sub, 
id_sched,
dt_mod,
rs_begintype, 
rs_beginoffset, 
rs_beginbase,
rs_endtype, 
rs_endoffset, 
rs_endbase, 
id_pricelist,
tmInnerrowid,
rschedInnerrowid,
teInnerrowid
)
/*BUILD IMMEDIATE REFRESH FAST ON COMMIT */
as
select
tmInner.id_po as id_po,
tmInner.id_paramtable as id_paramtable,
tmInner.id_pi_instance as id_pi_instance,
tmInner.id_pi_template as id_pi_template,
to_number(NULL) as id_sub,
rschedInner.id_sched as id_sched,
rschedInner.dt_mod as dt_mod,
teInner.n_begintype as rs_begintype, 
teInner.n_beginoffset as rs_beginoffset,
teInner.dt_start as rs_beginbase, 
teInner.n_endtype as rs_endtype,
teInner.n_endoffset as rs_endoffset,
teInner.dt_end as rs_endbase,
rschedInner.id_pricelist as id_pricelist,
tmInner.rowid "tmInnerrowid", rschedInner.rowid "rschedInnerrowid",teInner.rowid "teInnerrowid"
from
t_pl_map tmInner
INNER JOIN t_rsched rschedInner on 
 rschedInner.id_pricelist = tmInner.id_pricelist 
 AND rschedInner.id_pt =tmInner.id_paramtable 
 AND rschedInner.id_pi_template = tmInner.id_pi_template
INNER JOIN t_effectivedate teInner on teInner.id_eff_date = rschedInner.id_eff_date
where tmInner.id_sub is null
  