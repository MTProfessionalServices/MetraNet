
       /*__GET_ACCOUNT_TYPE_NAME__*/
	select a.id_acc, at.name AccountTypeName, case count(ci.id_cap_instance) when 0 then 0 else 1 end HasLogonCapability
	  from t_account a
	  join t_account_type at on a.id_type = at.id_type
	  left join t_principal_policy pp_acc on pp_acc.id_acc = a.id_acc
	  left join t_policy_role pr on pp_acc.id_policy = pr.id_policy
	  left join t_principal_policy pp_p on pp_p.id_role = pr.id_role 
	  left join t_capability_instance ci on ci.id_policy = pp_p.id_policy
	  left join t_composite_capability_type cct on ci.id_cap_type = cct.id_cap_type and cct.tx_name = 'Application LogOn'
	where at.b_IsVisibleInHierarchy = 1 and a.id_acc = %%ID_ACC%%
	group by a.id_acc, at.name
