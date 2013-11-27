
      /* __CREATE_T_REPORT_INSTANCE_GEN_IF_NEEDED__ */
      begin
      if not table_exists('t_report_instance_gen') then
			exec_ddl('CREATE TABLE t_report_instance_gen (
			n_initiator_adapter_runid number(10) NOT NULL,
			n_initiator_adapter_billgrpid number(10) NOT NULL,
			n_report_runid number(10) NOT NULL,
			n_report_billgroupid number(10) NOT NULL,
			tx_initiator_adapter_name varchar2(255) NOT NULL,
			tx_rpt_template_unique_name varchar2(255) NOT NULL,
			n_expected_instances number(10) NOT NULL,
			tx_status varchar2(10) NOT NULL,
			tx_completor_adapter_name varchar2(255) NULL,
			n_completor_adapter_runid number(10) NULL,
			n_succeeded_instances number(10) NULL,
			n_failed_instances number(10) NULL,
			b_reached_threshold  VARCHAR2(1) NULL,
			b_reached_timeout varchar2(1) NULL)');
			end if;
		end;
		