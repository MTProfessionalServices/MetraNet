
      /* __GET_REPORT_RUN_ID__ */
 	  select * from (select n_report_runid as ParentRunID, n_report_billgroupid as ParentBillGroupID
					   from t_report_instance_gen where n_initiator_adapter_runid = %%ID_RUN%%
					   and n_initiator_adapter_billgrpid = %%ID_BILLGROUP%%) where rownum <= 1 
		