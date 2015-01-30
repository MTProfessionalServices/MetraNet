
            CREATE OR REPLACE FORCE VIEW t_vw_authentication_type
			AS
			  SELECT CASE WHEN COUNT(*) = 0 THEN 2 ELSE 1 END authentication_type, nm_login, nm_space
				FROM t_user_credentials
			  GROUP BY nm_login, nm_space
          