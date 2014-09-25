SELECT ac.c_Name,
       ac.c_AccountingCycle_Id
  FROM t_be_sys_rep_accountingcycle ac,
       t_be_sys_rep_accountingcycl acc2c
  WHERE ac.c_AccountingCycle_Id = acc2c.c_AccountingCycle_Id
  order by ac.c_IsDefault DESC, ac.c_Name