BEGIN
	DECLARE @sqlText NVARCHAR(256)
    DECLARE drop_fk CURSOR FOR
        SELECT 'ALTER TABLE ' + t.name + ' DROP CONSTRAINT ' + fk.name AS sqlText
		FROM   sys.tables t join sys.foreign_keys fk on t.object_id = fk.parent_object_id
		WHERE  t.name LIKE 'T\_PT\_%' ESCAPE '\'
		   AND EXISTS (SELECT 1
					   FROM   sys.tables st
							  JOIN sys.foreign_key_columns c
								ON st.object_id = c.referenced_object_id
					   WHERE  st.name = 't_rsched' and c.parent_object_id = t.object_id)

	OPEN drop_fk
	FETCH NEXT FROM drop_fk INTO @sqlText
    
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC (@sqlText)

		FETCH NEXT FROM drop_fk INTO @sqlText
	END

	CLOSE drop_fk
	DEALLOCATE drop_fk
END