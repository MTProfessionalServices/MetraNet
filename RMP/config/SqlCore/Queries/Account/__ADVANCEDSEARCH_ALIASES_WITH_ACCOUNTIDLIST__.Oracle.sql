SELECT * FROM (
select distinct /*"_ACCOUNTID", "USERNAME", "NAME_SPACE"*/ iq1.*,
	(SELECT CASE COUNT(ci.id_cap_instance) WHEN 0 THEN 0 ELSE 1 END 
	FROM t_principal_policy pp_acc
	LEFT JOIN t_policy_role pr on pp_acc.id_policy = pr.id_policy
	LEFT JOIN t_principal_policy pp_p on pp_p.id_role = pr.id_role 
	LEFT JOIN t_capability_instance ci on ci.id_policy = pp_p.id_policy
	LEFT JOIN t_composite_capability_type cct on ci.id_cap_type = cct.id_cap_type and cct.tx_name = 'Application LogOn'
	WHERE pp_acc.id_acc = iq1."_ACCOUNTID") HasLogonCapability,
	(SELECT CASE COUNT(1) WHEN 0 THEN 0 ELSE 1 END
	FROM t_acctype_descendenttype_map map 
	JOIN t_account_type tat ON map.id_descendent_type = tat.id_type 
	WHERE map.id_type = iq1."ACCOUNTTYPEID" AND (UPPER(tat.name) <> UPPER('%%ALLTYPESACCOUNTTYPENAME%%') OR '%%ALLTYPESACCOUNTTYPENAME%%' IS NULL)) CanHaveChildren
	 %%SORT_COLUMN%%
from (%%INNER_QUERY%%) iq1) iq2 WHERE ("_ACCOUNTID") IN (%%ACCOUNTIDLIST%%)
			