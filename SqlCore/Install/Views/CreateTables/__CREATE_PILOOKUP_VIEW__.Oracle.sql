
create or replace force  view t_vw_pilookup
(
dt_start,
dt_end,
nm_name,
id_acc,
id_pi_template,
id_po,
id_pi_instance,
id_sub
)
as
select
sub.dt_start dt_start,
sub.dt_end dt_end,
base.nm_name,
sub.id_acc id_acc,
typemap.id_pi_template,
typemap.id_po,
typemap.id_pi_instance,
sub.id_sub
from
t_vw_effective_subs sub
 INNER JOIN t_pl_map typemap on typemap.id_po = sub.id_po AND
  typemap.id_po = sub.id_po and typemap.id_paramtable is null
 INNER JOIN t_base_props base on base.id_prop=typemap.id_pi_template
