
create view t_vw_allrateschedules_pl
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
id_pricelist)
with SCHEMABINDING
as
select 
null as id_po,
mapInner.id_pt as id_paramtable,
null as id_pi_instance,
templateInner.id_template as id_pi_template,
null as id_sub,
trInner.id_sched as id_sched,
trInner.dt_mod as dt_mod,
teInner.n_begintype as rs_begintype, 
teInner.n_beginoffset as rs_beginoffset,
teInner.dt_start as rs_beginbase, 
teInner.n_endtype as rs_endtype,
teInner.n_endoffset as rs_endoffset,
teInner.dt_end as rs_endbase,
trInner.id_pricelist as id_pricelist
from dbo.t_rsched trInner
INNER JOIN dbo.t_effectivedate teInner ON teInner.id_eff_date = trInner.id_eff_date
-- XXX fix this by passing in the instance ID
INNER JOIN dbo.t_pi_template templateInner on templateInner.id_template=trInner.id_pi_template
INNER JOIN dbo.t_pi_rulesetdef_map mapInner ON mapInner.id_pi = templateInner.id_pi and trInner.id_pt = mapInner.id_pt
		