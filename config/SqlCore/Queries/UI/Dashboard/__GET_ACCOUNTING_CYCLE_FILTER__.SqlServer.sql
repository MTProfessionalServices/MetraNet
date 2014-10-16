SELECT DISTINCT
       ac.c_Name,
       ac.c_AccountingCycle_Id,
       ac.c_Cycle,
       ac.c_Day,
       ac.c_IsDefault
  FROM t_be_sys_rep_accountingcycle ac,
       t_be_sys_rep_accountingcycl acc2c
  WHERE ac.c_AccountingCycle_Id = acc2c.c_AccountingCycle_Id
	OR ac.c_IsDefault = 'T'
  ORDER BY ac.c_IsDefault DESC, ac.c_Name