
			create or replace procedure TestStoredProc(p_ID_BILLGROUP int, p_ID_RUN int, p_NETMETER_DB_NAME nvarchar2)
		  	as
		  	strQuery varchar2(3000);
			begin
				strQuery := 'insert into t_rpt_test_account select amap.id_acc, bgm.id_billgroup, amap.nm_login'
							|| ' from ' || p_NETMETER_DB_NAME || '.t_account_mapper amap inner join '
							|| p_NETMETER_DB_NAME || '.t_billgroup_member bgm on amap.id_acc = bgm.id_acc where'
							|| ' bgm.id_billgroup = ' || to_char(p_ID_BILLGROUP);
				execute immediate (strQuery);


				strQuery := 'insert into ' || p_NETMETER_DB_NAME || '.t_recevent_run_details values ('
                            || p_NETMETER_DB_NAME || '.seq_t_recevent_run_details.nextval,'
							|| to_char(p_ID_RUN) ||', ''Info'', ''done testing idrun'' , SYSDATE)';
				execute immediate (strQuery);
				return;
			end;
	   