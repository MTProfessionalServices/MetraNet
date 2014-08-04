select amap.id_descendent_type as DescendentTypeId,
	   accType.name as DescendentTypeName
from t_acctype_descendenttype_map amap
join t_account_type accType
	on (amap.id_descendent_type = accType.id_type)
    where amap.id_type = (select id_type from t_account_type at where at.name = '%%ACCOUNT_TYPE_NAME%%')