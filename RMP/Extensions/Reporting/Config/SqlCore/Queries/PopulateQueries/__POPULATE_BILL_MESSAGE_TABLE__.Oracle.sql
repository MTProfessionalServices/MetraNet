begin
  INSERT INTO %%t_rpt_bill_messages
	SELECT
			Invoice.id_invoice InvoiceID,
			Invoice.invoice_string InvoiceString,
			Invoice.id_acc AccountID,
			Invoice.id_interval IntervalID,
			
			bm.c_MessageType MessageType,
			bm.c_MessageText MessageText,
			bm.c_MessageFormat MessageFormat
			
	        FROM %%NETMETER_DB_NAME%%.t_invoice Invoice
		        JOIN %%NETMETER_DB_NAME%%.t_be_cor_bil_billmessageac_h bma
			on Invoice.id_acc = bma.c_AccountId
			    JOIN %%NETMETER_DB_NAME%%.t_be_cor_bil_billmessage_h bm
			on bma.c_BillMessage_Id = bm.c_BillMessage_Id
			    JOIN %%NETMETER_DB_NAME%%.t_usage_interval ui
			on ui.id_interval = Invoice.id_interval
			    JOIN %%NETMETER_DB_NAME%%.t_billgroup_member bgm
			on Invoice.id_acc = bgm.id_acc			
								
	WHERE
			bgm.id_billgroup = %%ID_BILLGROUP%%
			AND  
			c_StartDate < ui.dt_end
			AND
			(c_EndDate > ui.dt_start OR c_EndDate IS NULL)
			
	GROUP BY Invoice.id_invoice, Invoice.invoice_string, Invoice.id_acc, Invoice.id_interval,bm.c_MessageType, bm.c_MessageFormat, bm.c_MessageText;
end; 	
