
		      BEGIN
			      TestSplitStoredProc('%%NETMETER_DB_NAME%%', '%%PARENT_DB_NAME%%', %%PARENT_ID_BILLGROUP%%, %%PARENT_ID_RUN%%, '%%CHILD_DB_NAME%%', %%CHILD_ID_BILLGROUP%%, %%CHILD_ID_RUN%%);

			      EXCEPTION
				      WHEN OTHERS THEN
					      dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
				      RAISE;
		      END;
	      