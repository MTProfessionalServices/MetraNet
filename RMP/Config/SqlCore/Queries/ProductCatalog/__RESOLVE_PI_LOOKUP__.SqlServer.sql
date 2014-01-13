
select	arg.id_request, sub.id_sub, typemap.id_po, typemap.id_pi_template, typemap.id_pi_instance
from
	%%TABLE_NAME%% arg WITH(READCOMMITTED)
           inner join t_gsubmember tgs on arg.id_acc = tgs.id_acc
	   inner join t_sub sub on sub.id_group = tgs.id_group 
	   inner join dbo.t_pl_map typemap on typemap.id_po = sub.id_po and typemap.id_paramtable is null
	   inner join dbo.t_base_props base on base.id_prop=typemap.id_pi_template
	where
	(tgs.vt_start <= arg.dt_session) and
	(tgs.vt_end >= arg.dt_session) and
	(((arg.id_pi_template is null) and (arg.nm_pi_name = base.nm_name)) or
	((arg.nm_pi_name is null) and (arg.id_pi_template = typemap.id_pi_template)))
union all
select	arg.id_request, sub.id_sub, typemap.id_po, typemap.id_pi_template, typemap.id_pi_instance
from
	%%TABLE_NAME%% arg WITH(READCOMMITTED)
           inner join t_sub sub on arg.id_acc = sub.id_acc
	   inner join dbo.t_pl_map typemap on typemap.id_po = sub.id_po and typemap.id_paramtable is null
	   inner join dbo.t_base_props base on base.id_prop=typemap.id_pi_template
	where
	(sub.vt_start <= arg.dt_session) and
	(sub.vt_end >= arg.dt_session) and
	(((arg.id_pi_template is null) and (arg.nm_pi_name = base.nm_name)) or
	((arg.nm_pi_name is null) and (arg.id_pi_template = typemap.id_pi_template)))
	 and sub.id_group IS NULL
  		