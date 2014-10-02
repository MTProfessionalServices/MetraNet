/*
===========================================================
  Assign billing groups by Partition and Continent
===========================================================
*/
/* assigns constraint groups (and the accounts contained in them) to billing groups */
INSERT INTO t_billgroup_member_tmp (id_materialization, id_acc, tx_name, id_partition)
SELECT 
	%%ID_MATERIALIZATION%%, 
	cg.id_acc,
  CASE av.tx_country
    WHEN N'Global/CountryName/USA'            THEN tamap.nm_login + N' North America'
    WHEN N'Global/CountryName/Canada'         THEN tamap.nm_login + N' North America'
    WHEN N'Global/CountryName/Mexico'         THEN tamap.nm_login + N' North America'
    WHEN N'Global/CountryName/Argentina'      THEN tamap.nm_login + N' South America'
    WHEN N'Global/CountryName/Brazil'         THEN tamap.nm_login + N' South America'
    WHEN N'Global/CountryName/United Kingdom' THEN tamap.nm_login + N' Europe'
    ELSE tamap.nm_login + N' Default' END,
  tamap.id_acc
FROM t_billgroup_constraint_tmp cg
JOIN
(
	SELECT 
		id_group,
		MAX(id_acc) id_acc
	FROM t_billgroup_constraint_tmp
	GROUP BY id_group
) singleacc ON singleacc.id_group = cg.id_group
JOIN t_account_mapper amap on cg.id_acc = amap.id_acc
JOIN t_namespace ns on amap.nm_space = ns.nm_space and lower(ns.tx_typ_space) = 'system_mps' and lower(ns.nm_method) = 'partition'
JOIN t_account_mapper tamap on lower(tamap.nm_login) = lower(ns.nm_space) and lower(tamap.nm_space) = 'mt'
LEFT OUTER JOIN 
(
  SELECT 
    id_acc, 
    country.nm_enum_data tx_country
  FROM t_av_contact av
  INNER JOIN t_enum_data country ON country.id_enum_data = av.c_country
  INNER JOIN t_enum_data contacttype ON contacttype.id_enum_data = av.c_contacttype
  WHERE %%%UPPER%%%(contacttype.nm_enum_data) = %%%UPPER%%%(N'metratech.com/accountcreation/contacttype/bill-to')
) av ON av.id_acc = singleacc.id_acc

UNION ALL
SELECT 
  %%ID_MATERIALIZATION%%, 
  cg.id_acc,
  CASE av.tx_country
    WHEN N'Global/CountryName/USA'            THEN t_account_mapper.nm_login + N' North America'
    WHEN N'Global/CountryName/Canada'         THEN t_account_mapper.nm_login + N' North America'
    WHEN N'Global/CountryName/Mexico'         THEN t_account_mapper.nm_login + N' North America'
    WHEN N'Global/CountryName/Argentina'      THEN t_account_mapper.nm_login + N' South America'
    WHEN N'Global/CountryName/Brazil'         THEN t_account_mapper.nm_login + N' South America'
    WHEN N'Global/CountryName/United Kingdom' THEN t_account_mapper.nm_login + N' Europe'
    ELSE t_account_mapper.nm_login + N' Default' END,
  t_account_mapper.id_acc
FROM t_billgroup_constraint_tmp cg
JOIN
(
  SELECT 
    id_group,
    MAX(id_acc) id_acc
  FROM t_billgroup_constraint_tmp
  GROUP BY id_group
) singleacc ON singleacc.id_group = cg.id_group
JOIN t_account on cg.id_acc = t_account.id_acc
JOIN t_account_type on t_account.id_type = t_account_type.id_type and lower(t_account_type.name) = 'partition'
JOIN t_account_mapper on cg.id_acc = t_account_mapper.id_acc and lower(t_account_mapper.nm_space) = 'mt'
LEFT OUTER JOIN 
(
  SELECT 
    id_acc, 
    country.nm_enum_data tx_country
  FROM t_av_contact av
  INNER JOIN t_enum_data country ON country.id_enum_data = av.c_country
  INNER JOIN t_enum_data contacttype ON contacttype.id_enum_data = av.c_contacttype
  WHERE %%%UPPER%%%(contacttype.nm_enum_data) = %%%UPPER%%%(N'metratech.com/accountcreation/contacttype/bill-to')
) av ON av.id_acc = singleacc.id_acc

UNION ALL
SELECT 
	%%ID_MATERIALIZATION%%, 
	cg.id_acc,
  CASE av.tx_country
    WHEN N'Global/CountryName/USA'            THEN N'North America'
    WHEN N'Global/CountryName/Canada'         THEN N'North America'
    WHEN N'Global/CountryName/Mexico'         THEN N'North America'
    WHEN N'Global/CountryName/Argentina'      THEN N'South America'
    WHEN N'Global/CountryName/Brazil'         THEN N'South America'
    WHEN N'Global/CountryName/United Kingdom' THEN N'Europe'
    ELSE N'Default' END,
  Null
FROM t_billgroup_constraint_tmp cg
JOIN
(
	SELECT 
		id_group,
		MAX(id_acc) id_acc
	FROM t_billgroup_constraint_tmp
	GROUP BY id_group
) singleacc ON singleacc.id_group = cg.id_group
JOIN t_account_mapper amap on cg.id_acc = amap.id_acc
JOIN t_namespace ns on amap.nm_space = ns.nm_space and lower(ns.tx_typ_space) = 'system_mps' and (ns.nm_method IS NULL OR lower(ns.nm_method) !=  'partition')
LEFT OUTER JOIN 
(
  SELECT 
    id_acc, 
    country.nm_enum_data tx_country
  FROM t_av_contact av
  INNER JOIN t_enum_data country ON country.id_enum_data = av.c_country
  INNER JOIN t_enum_data contacttype ON contacttype.id_enum_data = av.c_contacttype
  WHERE %%%UPPER%%%(contacttype.nm_enum_data) = %%%UPPER%%%(N'metratech.com/accountcreation/contacttype/bill-to')
) av ON av.id_acc = singleacc.id_acc
WHERE amap.id_acc NOT IN
(
  SELECT 
    t_account.id_acc
  FROM t_account
  INNER JOIN t_account_type on t_account.id_type = t_account_type.id_type and t_account_type.name = 'Partition'
  INNER JOIN t_account_mapper on t_account.id_acc = t_account_mapper.id_acc  and t_account_mapper.nm_space = 'mt'
)