
CREATE OR REPLACE VIEW vw_bus_partition_accounts (id_acc,
                                     id_partition,
                                     partition_name,
                                     partition_nm_space
                                    )
AS
  SELECT      aa.id_descendent id_acc, 
              a.id_acc id_partition, 
              am.nm_login partition_name, 
              am.nm_space partition_namespace 
  FROM        t_account a
        INNER JOIN t_account_type at ON a.id_type = at.id_type 
        INNER JOIN t_account_ancestor aa ON a.id_acc = aa.id_ancestor and aa.vt_end >= TO_DATE('2038-01-01', 'YYYY-MM-DD')
        INNER JOIN t_account_mapper am on am.id_acc = a.id_acc
  WHERE       at.name = 'Partition'

