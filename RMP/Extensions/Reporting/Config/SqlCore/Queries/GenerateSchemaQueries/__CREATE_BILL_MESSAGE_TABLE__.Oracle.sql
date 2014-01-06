   begin
 		   if NOT table_exists('t_rpt_bill_messages') then
 		   execute immediate '
 		   CREATE TABLE t_rpt_bill_messages (
			InvoiceID number(10) NOT NULL,
			InvoiceString nvarchar2(50) NOT NULL,
			AccountID number(10) NOT NULL,
			IntervalID number(10) NOT NULL,
			MessageType number(10) NOT NULL,
			MessageText nvarchar2(2000) NOT NULL,
			MessageFormat nvarchar2(20) NULL
			)';
			end if;
		end;
		