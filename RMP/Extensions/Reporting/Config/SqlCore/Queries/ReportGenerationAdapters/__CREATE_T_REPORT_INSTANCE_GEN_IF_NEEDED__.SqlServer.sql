
      /* __CREATE_T_REPORT_INSTANCE_GEN_IF_NEEDED__ */
      if not 
			exists (select * from sysobjects where name = 't_report_instance_gen')
			begin
			CREATE TABLE t_report_instance_gen (
			n_initiator_adapter_runid int NOT NULL,
			n_initiator_adapter_billgrpid int NOT NULL,
			n_report_runid int NOT NULL,
			n_report_billgroupid int NOT NULL,
			tx_initiator_adapter_name varchar (255) NOT NULL,
			tx_rpt_template_unique_name varchar (255) NOT NULL,
			n_expected_instances int NOT NULL,
			tx_status varchar (10) NOT NULL,
			tx_completor_adapter_name varchar (255) NULL,
			n_completor_adapter_runid int NULL,
			n_succeeded_instances int NULL,
			n_failed_instances int NULL,
			b_reached_threshold varchar NULL,
			b_reached_timeout varchar NULL,
			)
			end
			