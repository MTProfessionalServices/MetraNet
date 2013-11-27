
		    CREATE PROCEDURE PurgeAuditTable @dt_start varchar(255),
		                                     @ret_code int OUTPUT
		    AS
		    BEGIN
			    DELETE FROM t_audit
			    WHERE dt_crt <= @dt_start
			    IF (@@error != 0)
			    BEGIN
				    SELECT @ret_code = -99
			    END
			    ELSE
			    BEGIN
				    SELECT @ret_code = 0
			    END
			END
            