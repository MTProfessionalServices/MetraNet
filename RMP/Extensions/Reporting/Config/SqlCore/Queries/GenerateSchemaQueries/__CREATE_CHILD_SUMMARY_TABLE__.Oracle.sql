
	   begin
 		if NOT table_exists('t_rpt_child_summary') then
 		execute immediate '
			Create table t_rpt_child_summary(
 			InvoiceID number(10) NOT NULL,
 			ParentSessID number(10) NOT NULL,
			ChildSessID number(10) NOT NULL,
 			ChildDesc nvarchar2(100) NOT NULL,
 			Attendee nvarchar2(510),
 			CallNumber nvarchar2(76),
 			Type nvarchar2(255),
 			Minutes number(22,10),
 			Charge  number(22,10)
			)';
			end if;
		end;
	   