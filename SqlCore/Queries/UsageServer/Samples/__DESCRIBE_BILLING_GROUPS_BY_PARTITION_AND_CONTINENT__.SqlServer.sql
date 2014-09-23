/*
===========================================================
  Describe billing groups by Partition and Continent
===========================================================
*/
INSERT INTO t_billgroup_tmp (id_materialization, tx_name, tx_description, id_partition)
SELECT DISTINCT 
  %%ID_MATERIALIZATION%%, 
  tx_name,
    CASE tx_name 
    WHEN N'North America ' + CONVERT(varchar(10), id_partition) THEN N'Accounts with Bill-To addresses residing in a North American country in ' + tx_name
    WHEN N'South America ' + CONVERT(varchar(10), id_partition) THEN N'Accounts with Bill-To addresses residing in a South American country in ' + tx_name 
    WHEN N'Europe ' + CONVERT(varchar(10), id_partition) THEN N'Accounts with Bill-To addresses residing in an European country in ' + tx_name  
    WHEN N'Default ' + CONVERT(varchar(10), id_partition) THEN N'Accounts that did not match other billing group rules in ' + tx_name 
    WHEN N'North America' THEN N'Accounts with Bill-To addresses residing in a North American country'
    WHEN N'South America' THEN N'Accounts with Bill-To addresses residing in a South American country' 
    WHEN N'Europe' THEN N'Accounts with Bill-To addresses residing in an European country'  
    WHEN N'Default' THEN N'Accounts that did not match other billing group rules'
    END as description,
  id_partition
FROM t_billgroup_member_tmp
WHERE id_materialization = %%ID_MATERIALIZATION%%
ORDER BY tx_name
