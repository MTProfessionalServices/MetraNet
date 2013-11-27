
insert into t_pl_map (dt_modified, id_paramtable, id_pi_type, id_pi_template, id_pi_instance, id_pi_instance_parent, id_sub, id_acc, id_po, id_pricelist, b_canICB)
select %%%SYSTEMDATE%%%, %%ID_PT%%, plm.id_pi_type, plm.id_pi_template, plm.id_pi_instance, plm.id_pi_instance_parent, plm.id_sub, plm.id_acc, plm.id_po, plm.id_pricelist, plm.b_canICB
from t_pl_map plm
where 
id_pi_type=%%ID_PI%%
and
id_paramtable is null
and
not exists (
	select * from t_pl_map plm2
	where 
	plm2.id_paramtable=%%ID_PT%% 
	and 
	plm2.id_pi_instance=plm.id_pi_instance
)
      