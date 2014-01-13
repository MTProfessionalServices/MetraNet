            BEGIN TRY
				IF EXISTS (SELECT * FROM syslogins where name =
				'%%DBO_LOGON%%') EXEC sp_droplogin '%%DBO_LOGON%%'
			END TRY
            BEGIN CATCH
                PRINT 'Unable to drop user %%DBO_LOGON%%'
            END CATCH