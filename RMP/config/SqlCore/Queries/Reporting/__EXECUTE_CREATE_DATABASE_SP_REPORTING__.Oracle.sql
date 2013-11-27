
		DECLARE
		p_return_code INTEGER;
		BEGIN
			/*  Now call the stored program */
			createreportingdb('%%DB_NAME%%','%%NETMETER_DB_NAME%%','%%DATA_LOG_PATH%%',%%DB_SIZE%%,p_return_code);

			EXCEPTION
				WHEN OTHERS THEN
					dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
				RAISE;
		END;
		