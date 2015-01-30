
				create OR REPLACE FUNCTION mtmaxdate
			  RETURN DATE
			   IS
				  temp_time   DATE;
			   BEGIN
					select to_date('01/01/2038 00:00','dd/mm/yyyy hh24:mi') into TEMP_time from dual;
				return (temp_time); 
			   END;
		