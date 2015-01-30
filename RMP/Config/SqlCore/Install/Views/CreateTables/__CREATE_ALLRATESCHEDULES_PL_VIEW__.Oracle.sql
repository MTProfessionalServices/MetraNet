
create /* MATERIALIZED view */ or replace view t_vw_allrateschedules_pl
/* BUILD IMMEDIATE REFRESH FAST ON COMMIT */
as
select 
to_number(null,5)  as id_po,
mapInner.id_pt as id_paramtable,
to_number(null,5)  as id_pi_instance,
templateInner.id_template as id_pi_template,
to_number(null,5)  as id_sub,
trInner.id_sched as id_sched,
trInner.dt_mod as dt_mod,
teInner.n_begintype as rs_begintype, 
teInner.n_beginoffset as rs_beginoffset,
/* teInner.dt_start as rs_beginbase, */
NVL(teInner.dt_start, TO_DATE('1970-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) as rs_beginbase,
teInner.n_endtype as rs_endtype,
teInner.n_endoffset as rs_endoffset,
/* teInner.dt_end as rs_endbase, */
NVL(teInner.dt_end, TO_DATE('2038-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')) as rs_endbase,
trInner.id_pricelist as id_pricelist,
teInner.rowid "teInnerrowid", 
trInner.rowid "rschedInnerrowid",
templateInner.rowid "templateInnerrowid", 
mapInner.rowid "mapInnerrowid"
from t_rsched trInner
INNER JOIN t_effectivedate teInner ON teInner.id_eff_date = trInner.id_eff_date
INNER JOIN t_pi_template templateInner on templateInner.id_template=trInner.id_pi_template
INNER JOIN t_pi_rulesetdef_map mapInner ON mapInner.id_pi = templateInner.id_pi and trInner.id_pt = mapInner.id_pt
   