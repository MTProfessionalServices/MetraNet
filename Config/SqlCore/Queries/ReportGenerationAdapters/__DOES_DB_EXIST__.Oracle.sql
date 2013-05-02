
			SELECT COUNT(*)as DbFound FROM all_users WHERE UPPER(username) = UPPER('%%REPORTING_DB_NAME%%')
			