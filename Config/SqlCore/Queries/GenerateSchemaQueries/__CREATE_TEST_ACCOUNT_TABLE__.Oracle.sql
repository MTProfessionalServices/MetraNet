
	   begin
 		if NOT table_exists ('t_rpt_test_account') then
 			execute immediate '
			Create table t_rpt_test_account(
 				AccountID number(10) NOT NULL,
 				BillgroupID number(10) NOT NULL,
				UserName nvarchar2(80))';
 		end if;
		end;
	   