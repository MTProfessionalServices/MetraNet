
INSERT INTO t_export_reports
           (c_report_title
           ,c_rep_type
           ,c_rep_def_source
           ,c_rep_query_source
           ,c_rep_query_tag
           ,c_report_desc
           ,c_prevent_adhoc_execution)
     VALUES
           ('Report1-DiscSchedNoParCSV'
           ,'Query'
           ,'Query'
           ,'\DataExport\config\queries'
           ,'__SELECT_ALL_ACCOUNTS__'
           ,'DiscSchedNoParCSV1'
           ,0)

INSERT INTO t_export_reports
           (c_report_title
           ,c_rep_type
           ,c_rep_def_source
           ,c_rep_query_source
           ,c_rep_query_tag
           ,c_report_desc
           ,c_prevent_adhoc_execution)
     VALUES
           ('Report2-DiscSchedNoParXML'
           ,'Query'
           ,'Query'
           ,'\DataExport\config\queries'
           ,'__SELECT_ALL_ACCOUNTS__'
           ,'DiscSchedNoParXML1'
           ,0)
		   
INSERT INTO t_export_reports
           (c_report_title
           ,c_rep_type
           ,c_rep_def_source
           ,c_rep_query_source
           ,c_rep_query_tag
           ,c_report_desc
           ,c_prevent_adhoc_execution)
     VALUES
           ('Report3-EOPWithParams'
           ,'Query'
           ,'Query'
           ,'\DataExport\config\queries'
           ,'__GET_ACCOUNT_CONTACT_SUMMARY_REPORT__'
           ,'description of testSchWithParams'
           ,0)