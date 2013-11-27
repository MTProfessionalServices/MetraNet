
 		if NOT EXISTS (select name from sysobjects where name = 't_rpt_test_account' and xtype = 'U')
		Create table t_rpt_test_account(
 			AccountID int NOT NULL,
 			BillgroupID int NOT NULL,
			UserName nvarchar(80)
 		)

	   