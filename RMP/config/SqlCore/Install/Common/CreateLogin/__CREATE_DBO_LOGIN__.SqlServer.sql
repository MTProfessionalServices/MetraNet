IF (SELECT CASE WHEN DB_NAME()LIKE '%STAGE%' THEN 0 ELSE 1 END AS DataBaseName) = 1
BEGIN
				IF NOT EXISTS (SELECT * FROM syslogins where name =
				'%%DBO_LOGON%%') EXEC sp_addlogin '%%DBO_LOGON%%', '%%DBO_PASSWORD%%'
END
			