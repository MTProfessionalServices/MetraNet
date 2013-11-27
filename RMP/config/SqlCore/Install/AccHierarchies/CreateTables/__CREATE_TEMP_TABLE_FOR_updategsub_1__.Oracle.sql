
				CREATE GLOBAL TEMPORARY TABLE tmp_updategsub_1
                (
                  ID_GROUP  NUMBER(38),
                  ID_ACC    NUMBER(38),
                  VT_START  DATE      ,
                  VT_END    DATE      ,
                  TT_END    DATE      
                )
				ON COMMIT PRESERVE ROWS
				