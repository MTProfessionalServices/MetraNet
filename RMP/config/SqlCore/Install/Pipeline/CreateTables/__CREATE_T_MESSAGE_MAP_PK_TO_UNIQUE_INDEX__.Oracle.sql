	
	  ALTER TABLE T_MESSAGE ADD (
	  CONSTRAINT PK_T_MESSAGE 
	  PRIMARY KEY ( ID_MESSAGE, ID_PARTITION)
		USING INDEX)
	  