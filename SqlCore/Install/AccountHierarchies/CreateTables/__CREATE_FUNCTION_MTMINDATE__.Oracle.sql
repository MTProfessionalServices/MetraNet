
			create OR REPLACE FUNCTION mtmindate
		  RETURN DATE
		   AS
			  temp_time   DATE;
		   BEGIN
			  SELECT TO_DATE ('01/01/1753 00:00', 'dd/mm/yyyy hh24:mi')
				INTO temp_time
				FROM DUAL;

			  RETURN (temp_time);
		   END;
			