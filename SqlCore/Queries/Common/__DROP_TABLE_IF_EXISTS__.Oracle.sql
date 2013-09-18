BEGIN
	IF table_exists('%%TABLE_NAME%%') THEN
	    EXECUTE IMMEDIATE 'drop table %%TABLE_NAME%%';
	END IF;
END;