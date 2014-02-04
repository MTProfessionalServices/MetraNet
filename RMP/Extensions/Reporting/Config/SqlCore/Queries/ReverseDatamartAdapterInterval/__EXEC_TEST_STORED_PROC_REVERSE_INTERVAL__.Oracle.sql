
		BEGIN
			/*  Now call the stored program */
			ReverseTestStoredProc(-1,%%ID_RUN%%,'%%NETMETER_DB_NAME%%');

			EXCEPTION
				WHEN OTHERS THEN
					dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
				RAISE;
		END;
	   