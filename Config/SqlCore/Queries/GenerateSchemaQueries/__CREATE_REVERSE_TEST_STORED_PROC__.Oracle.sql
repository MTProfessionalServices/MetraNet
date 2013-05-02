
			create or replace procedure ReverseTestStoredProc(p_ID_BILLGROUP int, p_ID_RUN int, p_NETMETER_DB_NAME nvarchar2)
		  	as
		  	strQuery varchar2(3000);
			begin
				strQuery := 'delete from t_rpt_test_account where BillgroupID = ' || to_char(p_ID_BILLGROUP);
				execute immediate (strQuery);
				
				strQuery := 'insert into ' || p_NETMETER_DB_NAME || '.t_recevent_run_details values ('
							|| p_NETMETER_DB_NAME || '.seq_t_recevent_run_details.nextval,'
							|| to_char(p_ID_RUN) || ', ''Info'', ''done testing reverse idrun'' , SYSDATE)';
				execute immediate (strQuery);
			return;
			end;
	   