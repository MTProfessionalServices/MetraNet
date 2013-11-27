
/* assigns constraint groups (and the accounts contained in them) to billing groups */
INSERT INTO t_billgroup_member_tmp (id_materialization, id_acc, tx_name)
SELECT 
  %%ID_MATERIALIZATION%%, 
  cg.id_acc,
  CASE av.tx_country
    WHEN N'Global/CountryName/USA'          THEN N'North America'
    WHEN N'Global/CountryName/Canada'     THEN N'North America'
    WHEN N'Global/CountryName/Mexico'     THEN N'North America'
    WHEN N'Global/CountryName/Argentina' THEN N'South America'
    WHEN N'Global/CountryName/Brazil'        THEN N'South America'
    WHEN N'Global/CountryName/United Kingdom'        THEN N'Europe'
    ELSE N'Default' END
FROM t_billgroup_constraint_tmp cg
INNER JOIN 
(
  /* chooses one account from the the constraint group 
     to be used as the basis for assignment.
     in this case, we'll choose the maximal account ID - this is completely arbitrary
  */
  SELECT 
    id_group,
    MAX(id_acc) id_acc
  FROM t_billgroup_constraint_tmp GROUP BY id_group
) singleacc ON singleacc.id_group = cg.id_group
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
   