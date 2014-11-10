
            CREATE OR REPLACE FORCE VIEW t_vw_user_credentials
			AS
			  SELECT
					m.nm_login,
					m.nm_space,
					c.tx_password,
					(CASE WHEN c.tx_password IS NULL THEN 2 ELSE 1 END) authentication_type
				FROM t_account_mapper m
				     LEFT JOIN t_user_credentials c ON c.nm_login = m.nm_login AND c.nm_space = m.nm_space
          