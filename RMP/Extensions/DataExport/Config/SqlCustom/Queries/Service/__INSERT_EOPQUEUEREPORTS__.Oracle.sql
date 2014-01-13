
				BEGIN
					export_QueueEOPReports('%%EOP_INSTANCE_NAME%%', %%ID_INTERVAL%%, %%ID_BILLGROUP%%, %%ID_RUN%%);
				END;	
			