
DELETE FROM t_path_capability where id_cap_instance in
	(select id_cap_instance from 
			t_account_mapper am
			inner join
			t_principal_policy pp on am.id_acc = pp.id_acc
			inner join
			t_capability_instance pathCI on pp.id_policy = pathCI.id_policy  and pathCI.id_parent_cap_instance is not null
			inner join
			t_atomic_capability_type act on pathCI.id_cap_type = act.id_cap_type
		where
			act.tx_name = 'MTPathCapability'
			and
			nm_login = 'su');
			

DELETE FROM t_enum_capability where id_cap_instance in
	(select id_cap_instance from 
			t_account_mapper am
			inner join
			t_principal_policy pp on am.id_acc = pp.id_acc
			inner join
			t_capability_instance pathCI on pp.id_policy = pathCI.id_policy  and pathCI.id_parent_cap_instance is not null
			inner join
			t_atomic_capability_type act on pathCI.id_cap_type = act.id_cap_type
		where
			act.tx_name = 'MTEnumTypeCapability'
			and
			nm_login = 'su');
			
DELETE FROM t_capability_instance where id_policy in
	(select id_policy from 
		t_account_mapper am
		inner join
		t_principal_policy pp on am.id_acc = pp.id_acc
	where
		nm_login = 'su');
		
exec GrantAllCapabilityToAccount 'su', 'system_user'
				