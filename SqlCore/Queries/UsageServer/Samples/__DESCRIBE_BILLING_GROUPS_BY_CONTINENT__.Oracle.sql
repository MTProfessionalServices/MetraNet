
/* ===========================================================
  Describe billing groups by continent
  ===========================================================
*/
INSERT INTO t_billgroup_tmp (
  id_billgroup, id_materialization, tx_name, tx_description)
select 
  seq_t_billgroup_tmp.nextval, id_materialization, tx_name, continent
from (
  SELECT DISTINCT 
    %%ID_MATERIALIZATION%% as id_materialization, 
    tx_name,
    CASE tx_name 
    WHEN N'North America' THEN N'Accounts with Bill-To addresses residing in a North American country' 
    WHEN N'South America' THEN N'Accounts with Bill-To addresses residing in a South American country' 
    WHEN N'Europe' THEN N'Accounts with Bill-To addresses residing in an European country' 
    WHEN N'Default' THEN N'Accounts that did not match other billing group rules'
    END as continent
  FROM t_billgroup_member_tmp
  WHERE id_materialization = %%ID_MATERIALIZATION%%
  order by tx_name
  ) subqry
 