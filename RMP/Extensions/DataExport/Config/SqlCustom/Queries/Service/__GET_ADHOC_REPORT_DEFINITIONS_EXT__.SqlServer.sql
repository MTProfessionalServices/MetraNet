
--drop table #caps

set nocount on
SELECT CI.ID_CAP_TYPE, cct.tx_name
into #caps
FROM
T_PRINCIPAL_POLICY app
INNER JOIN t_account_mapper am ON app.id_acc = am.id_acc
INNER JOIN T_POLICY_ROLE pr ON app.ID_POLICY = pr.ID_POLICY
INNER JOIN T_ROLE R ON PR.ID_ROLE = R.ID_ROLE
INNER JOIN T_PRINCIPAL_POLICY RPP ON R.ID_ROLE = RPP.ID_ROLE
INNER JOIN t_capability_instance ci ON RPP.ID_POLICY = CI.ID_POLICY
LEFT OUTER JOIN t_capability_instance parentci ON CI.ID_PARENT_CAP_INSTANCE = parentci.id_cap_instance
LEFT OUTER JOIN t_Composite_capability_type parentcct ON parentci.id_cap_type = parentcct.id_cap_type
LEFT OUTER JOIN t_atomic_capability_type act ON ci.id_cap_type = act.id_cap_type
LEFT OUTER JOIN t_Composite_capability_type cct ON ci.id_cap_type = cct.id_cap_type
WHERE  am.id_acc = %%CSR%% AND
	(am.nm_space) = (N'system_user')
AND app.policy_type = 'A'
UNION ALL
SELECT CI.ID_CAP_TYPE, cct.tx_name
FROM
T_PRINCIPAL_POLICY app
INNER JOIN t_account_mapper am ON app.id_acc = am.id_acc
INNER JOIN t_capability_instance ci ON APP.ID_POLICY = CI.ID_POLICY
LEFT OUTER JOIN t_capability_instance parentci ON CI.ID_PARENT_CAP_INSTANCE = parentci.id_cap_instance
LEFT OUTER JOIN t_Composite_capability_type parentcct ON parentci.id_cap_type = parentcct.id_cap_type
LEFT OUTER JOIN t_atomic_capability_type act ON ci.id_cap_type = act.id_cap_type
LEFT OUTER JOIN t_Composite_capability_type cct ON ci.id_cap_type = cct.id_cap_type
WHERE  am.id_acc = %%CSR%% AND
	(am.nm_space) = (N'system_user')
AND app.policy_type = 'A'

SELECT A.id_rep, c_report_title, c_report_desc, c_prevent_adhoc_execution 
FROM t_export_reports A
WHERE c_prevent_adhoc_execution = 0
AND (id_rep IN (select id_rep 
				from t_export_report_security
				where id_capability in 
				(select id_cap_type from #caps))
OR exists (select * from #caps where tx_name = 'Unlimited Capability'))
order by c_report_desc
	