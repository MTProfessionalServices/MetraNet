IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.mtsp_sys_schemascript') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.mtsp_sys_schemascript
GO

/*
The procedure returns a value of
 1: fatal errors occurred
 0: successful

--------------------------------------------------------------
It includes the following information:
Table columns
Column name, data type & length, identity, default, null/not null
Check constraints
Unique constraints
Primary key constraints
Clustered, non-clustered, column descending/ascending
Indexes
Uunique, non-unique, clustered, non-clustered, column descending/ascending
Foreign keys
Views

Caution: Used the un-documented internal system fields
--------------------------------------------------------------

CREATE TABLE t_sys_schema
(line_number int identity not null,
 line_text varchar(8000))


TRUNCATE TABLE t_sys_schema

DECLARE @return_code int
EXEC mtsp_sys_schemascript
'ningtest',
@return_code = @return_code OUTPUT

PRINT @return_code

*/
CREATE PROCEDURE mtsp_sys_schemascript
@schema_owner varchar(50),
@return_code int OUTPUT
AS
BEGIN
DECLARE 
@debug_flag bit,
@SQLError int,
@ErrMsg varchar(200),
@linetext varchar(8000),
-- select columns for table columns
@identityflag bit,
@identityseed bigint,
@identityincr int,
@pretablename varchar(128),
@pretableid int,
@oid int,
@otype char(2), 
@oname varchar(128), 
@cname varchar(128), 
@tyname varchar(128), 
@tylen varchar(10), 
@typrec varchar(10), 
@tyscale varchar(10), 
--@tylen smallint, 
--@typrec tinyint, 
--@tyscale tinyint, 
@isnullable int, 
@cdefaulttype char(2), 
@cdefaultname varchar(128),
@cdefaultsqltext varchar(8000),
-- select columns for constraints
@constname varchar(128), 
@consttext varchar(8000),
-- for PK
@varloop int,
@pkcolname varchar(128),
-- for indexes
@indid int, 
@indname varchar(128), 
@keyno int, 
@preindexid int,
@indcolname varchar(128),
@indclustered varchar(128),
@indunique varchar(128),
-- FK
@parenttbl varchar(128), 
@pcol varchar(128), 
@childtbl varchar(128), 
@ccol varchar(128),
@preparenttbl varchar(128), 
@prechildtbl varchar(128), 
@preconstname varchar(128),
@linetext2 varchar(8000),
@linetext3 varchar(8000)
-- end of select columns

SET NOCOUNT ON
SET @debug_flag = 1
SET @linetext = ''
SET @pretableid = -1
SET @pretablename = 'no table yet'


--
-- TABLE SECTION
--
-- Extract tables

--Table columns and column DEFAULT only 
DECLARE cur_TblCol CURSOR FOR 
SELECT 
	o.id oid, o.type otype, o.name oname, c.name cname, ty.name tyname, 
	CAST(c.length AS varchar(10)) tylen, CAST(c.prec AS varchar(10)) typrec, CAST(c.scale AS varchar(10)) tyscale, 
	c.isnullable, tmpdefault.cdefaulttype, tmpdefault.cdefaultname,
	tmpdefault.cdefaultsqltext,
	CASE WHEN c.colstat & 1 = 1 THEN 1 ELSE 0 END identityflag
FROM sysobjects o 
	INNER JOIN syscolumns c ON c.id = o.id
	INNER JOIN systypes ty ON ty.xusertype = c.xusertype
	LEFT OUTER JOIN
		(SELECT csd.id, csd.colid, od.xtype cdefaulttype, od.name cdefaultname, cmd.text cdefaultsqltext
		FROM sysconstraints csd 
			INNER JOIN sysobjects od ON od.id = csd.constid AND od.xtype = 'D'
			INNER JOIN syscomments cmd ON csd.constid = cmd.id
		) tmpdefault
		ON o.id = tmpdefault.id AND c.colid = tmpdefault.colid
WHERE o.uid = USER_ID(@schema_owner)
AND o.type = 'U' 
AND o.name <> 'dtproperties'
ORDER BY o.type, o.name, c.colorder

OPEN cur_TblCol 
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 RETURN 1

IF @debug_flag = 1 PRINT 'After opening the cursor'

FETCH cur_TblCol INTO 
@oid,
@otype, 
@oname, 
@cname, 
@tyname, 
@tylen, 
@typrec, 
@tyscale, 
@isnullable, 
@cdefaulttype, 
@cdefaultname,
@cdefaultsqltext,
@identityflag

WHILE @@FETCH_STATUS <> -1
BEGIN
	-- a new table
	IF @oid <> @pretableid 
	BEGIN
		-- close up the previous table object and insert the row if it exists
		IF @pretableid <> -1
		BEGIN
			-- add CHECK constraints here
			DECLARE cur_CheckConst CURSOR FOR 
			SELECT oc.name constname, cmc.text consttext
			FROM sysconstraints csc
				INNER JOIN sysobjects oc ON oc.id = csc.constid AND oc.type = 'C'
				INNER JOIN syscomments cmc ON csc.constid = cmc.id
			WHERE csc.id = @pretableid
			ORDER BY oc.name

			OPEN cur_CheckConst 
			SELECT @SQLError = @@ERROR
			IF @SQLError <> 0 RETURN 1

			FETCH cur_CheckConst INTO @constname, @consttext

			WHILE @@FETCH_STATUS <> -1
			BEGIN
				-- insert the last table column or the previous constraint
				SET @linetext = @linetext + ','
				INSERT INTO t_sys_schema (line_text) VALUES (@linetext)

				INSERT INTO t_sys_schema (line_text) VALUES ('CONSTRAINT ' + RTRIM(@constname))
				SET @linetext = 'CHECK ' + RTRIM(@consttext)

				FETCH cur_CheckConst INTO @constname, @consttext
			END -- check constraint while loop
			CLOSE cur_CheckConst 
			DEALLOCATE cur_CheckConst 
			-- end of CHECK constraints

			-- add UNIQUE constraint here
			DECLARE cur_UQConst CURSOR FOR 
			SELECT i.indid, cik.name keycolname
			FROM sysconstraints csc
				INNER JOIN sysobjects oc ON oc.id = csc.constid AND oc.xtype = 'UQ'
				INNER JOIN sysindexes i ON i.id = csc.id AND i.indid BETWEEN 1 AND 254 AND i.name = oc.name
				INNER JOIN sysindexkeys ik ON ik.id = csc.id AND ik.indid = i.indid
				INNER JOIN syscolumns cik ON cik.id = csc.id AND cik.colid = ik.colid
			WHERE csc.id = @pretableid
			ORDER BY i.indid, ik.keyno

			OPEN cur_UQConst 
			SELECT @SQLError = @@ERROR
			IF @SQLError <> 0 RETURN 1

			SET @preindexid = -1
			FETCH cur_UQConst INTO @indid, @indcolname

			WHILE @@FETCH_STATUS <> -1
			BEGIN
				-- a new unique constraint
				IF @indid <> @preindexid 
				BEGIN
					-- take care of the previous check constraint or column
					IF @preindexid = -1
					BEGIN
						SET @linetext = @linetext + ','
						INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
					END
					ELSE
					-- take care of the previous unique constraint
					BEGIN
						SET @linetext = @linetext + '),'
						INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
					END

					-- take care of the current unique constraint
					SET @linetext = 'UNIQUE (' + RTRIM(@indcolname)
				END
				ELSE
				-- current unique constraint, add one column
				BEGIN
					SET @linetext = @linetext + ',' + RTRIM(@indcolname)
				END

				SET @preindexid = @indid
				FETCH cur_UQConst INTO @indid, @indcolname
			END -- index while loop
			CLOSE cur_UQConst 
			DEALLOCATE cur_UQConst 

			IF @preindexid <> -1
			BEGIN
					SET @linetext = @linetext + ')' 
			END
			-- end of UNIQUE constraint 

			-- add PRIMARY KEY constraint here
			DECLARE cur_PKConst CURSOR FOR 
			SELECT 
				CASE WHEN (indexkey_property(csc.id, i.indid, ik.keyno, 'isdescending') = 1 )
					THEN RTRIM(cik.name) + ' DESC'
					ELSE cik.name END keycolname,
				CASE WHEN (i.status & 16) <> 0 THEN 'CLUSTERED' ELSE 'NONCLUSTERED' END indclustered
			FROM sysconstraints csc
				INNER JOIN sysobjects oc ON oc.id = csc.constid AND oc.xtype = 'PK'
				INNER JOIN sysindexes i ON i.id = csc.id AND i.indid BETWEEN 1 AND 254 AND i.name = oc.name
				INNER JOIN sysindexkeys ik ON ik.id = csc.id AND ik.indid = i.indid
				INNER JOIN syscolumns cik ON cik.id = csc.id AND cik.colid = ik.colid
			WHERE csc.id = @pretableid
			ORDER BY ik.keyno

			OPEN cur_PKConst 
			SELECT @SQLError = @@ERROR
			IF @SQLError <> 0 RETURN 1

			SET @varloop = 0
			FETCH cur_PKConst INTO @pkcolname, @indclustered

			WHILE @@FETCH_STATUS <> -1
			BEGIN
				IF @varloop = 0
				BEGIN
					-- insert the last table column or the previous constraint
					SET @linetext = @linetext + ','
					INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
					SET @linetext = 'PRIMARY KEY ' + RTRIM(@indclustered) + ' ( ' + RTRIM(@pkcolname)
				END
				ELSE
				BEGIN
					SET @linetext = @linetext + ',' + RTRIM(@pkcolname)
				END
				SET @varloop = @varloop + 1

				FETCH cur_PKConst INTO @pkcolname, @indclustered
			END -- PK constraint while loop
			CLOSE cur_PKConst 
			DEALLOCATE cur_PKConst 

			IF @varloop > 0
			BEGIN
				SET @linetext = @linetext + ' )' 
			END
			-- end of PK constraint

			SET @linetext = @linetext + ' )'
			INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
			INSERT INTO t_sys_schema (line_text) VALUES ('go')
			SET @linetext = ''
		END
		-- end of the previous table

		-- takes care of the associated indexes if they exist for the previous table
		DECLARE cur_index CURSOR FOR 
		SELECT i.indid, i.name indname, ik.keyno, 
			CASE WHEN (indexkey_property(i.id, i.indid, ik.keyno, 'isdescending') = 1 )
				THEN RTRIM(cik.name) + ' DESC'
				ELSE cik.name END indcolname,
			CASE WHEN (i.status & 2) <> 0 THEN 'UNIQUE' ELSE '' END indunique,
			CASE WHEN (i.status & 16) <> 0 THEN 'CLUSTERED' ELSE 'NONCLUSTERED' END indclustered
		FROM sysindexes i 
			INNER JOIN sysindexkeys ik ON ik.id = i.id AND ik.indid = i.indid
			INNER JOIN syscolumns cik ON cik.id = i.id AND cik.colid = ik.colid
		WHERE i.indid BETWEEN 1 AND 254 AND (i.status & 64)= 0
		AND i.id = @pretableid
		AND i.name NOT IN  -- not an index created for a constraint
			(SELECT od.name
 			FROM sysconstraints csd 
 				INNER JOIN sysobjects od ON od.id = csd.constid
 			WHERE csd.id = i.id)
		ORDER BY i.indid, ik.keyno

		OPEN cur_index 
		SELECT @SQLError = @@ERROR
		IF @SQLError <> 0 RETURN 1

		SET @preindexid = -1
		SET @indid = NULL
		SET @indcolname = NULL
		FETCH cur_index INTO @indid, @indname, @keyno, @indcolname, @indunique, @indclustered

		WHILE @@FETCH_STATUS <> -1
		BEGIN
			-- a new index
			IF @indid <> @preindexid 
			BEGIN
				-- take care of the previous index
				IF @preindexid <> -1
				BEGIN
					SET @linetext = @linetext + ' )'
					INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
					INSERT INTO t_sys_schema (line_text) VALUES ('go')
				END

				-- take care of the current index
				SET @linetext = 'CREATE ' + RTRIM(@indunique) + ' ' + RTRIM(@indclustered) + ' INDEX ' + RTRIM(@indname) + ' ON ' + RTRIM(@pretablename) 
					+ '(' + RTRIM(@indcolname)
			END
			ELSE
			-- current index, add one index column
			BEGIN
				SET @linetext = @linetext + ',' + RTRIM(@indcolname)
			END

			SET @preindexid = @indid
			FETCH cur_index INTO @indid, @indname, @keyno, @indcolname, @indunique, @indclustered
		END -- index while loop
		CLOSE cur_index 
		DEALLOCATE cur_index 

		-- insert the last index
		IF @preindexid <> -1
		BEGIN
			SET @linetext = @linetext + ' )'
			INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
			INSERT INTO t_sys_schema (line_text) VALUES ('go')
		END
		-- end of indexes for the previous table

		-- takes care of the first line of a new table
		SET @linetext = 'CREATE TABLE ' + RTRIM(@oname) + ' ( '
		INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
	END
	-- current table, insert one column
	ELSE
	BEGIN
		SET @linetext = @linetext + ','
		INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
	END

	SET @linetext = ''

	-- For every column including the 1st column
	--
	-- DATA TYPES
	-- bigint, int, smallint, tityint, bit, real
	-- money, smallmoney, datetime, smalldatetime
	-- table, timestamp, uniqueidentifier, sql_variant
	-- text, ntext, image
	--
	-- decimal[(p[,s])], numeric[(p[,s])]
	-- char(n), varchar(n), nchar(n), nvarchar(n)
	-- binary(n), varbinary(n)
	-- float(n)
	IF lower(@tyname) IN ('decimal', 'numeric')
	BEGIN
		SET @linetext = RTRIM(@cname) + ' ' + RTRIM(@tyname) + ' (' + RTRIM(@typrec) + ',' + RTRIM(@tyscale) + ') '
	END
	ELSE IF lower(@tyname) IN ('char', 'varchar', 'nchar', 'nvarchar', 'binary', 'varbinary', 'float')
	BEGIN
		SET @linetext = RTRIM(@cname) + ' ' + RTRIM(@tyname) + ' (' + RTRIM(@typrec) + ') '
	END
	ELSE
	BEGIN
		SET @linetext = RTRIM(@cname) + ' ' + RTRIM(@tyname)
	END

	-- Takes care of IDENTITY fields
	IF @identityflag = 1
	BEGIN
		SET @linetext = @linetext + ' IDENTITY (' 
			+ RTRIM(CAST(IDENT_SEED(@oname) AS VARCHAR(200)))
			+ ','
			+ RTRIM(CAST(IDENT_INCR(@oname) AS VARCHAR(200)))
			+ ')'
	END

	-- Takes care of Defaults
	IF @cdefaulttype = 'D'
	BEGIN
		SET @linetext = @linetext + ' DEFAULT ' + @cdefaultsqltext
	END

	IF @isnullable = 0
	BEGIN
		SET @linetext = @linetext + ' NOT NULL'
	END
	ELSE
	BEGIN
		SET @linetext = @linetext + ' NULL'
	END

SET @pretableid = @oid
SET @pretablename = @oname
FETCH cur_TblCol INTO 
@oid,
@otype, 
@oname, 
@cname, 
@tyname, 
@tylen, 
@typrec, 
@tyscale, 
@isnullable, 
@cdefaulttype, 
@cdefaultname,
@cdefaultsqltext,
@identityflag

END -- table column while loop
CLOSE cur_TblCol 
DEALLOCATE cur_TblCol 

-- insert the last column of the last table
IF @pretableid <> -1
BEGIN
	SET @linetext = @linetext + ' )'
	INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
	INSERT INTO t_sys_schema (line_text) VALUES ('go')
END

--
-- VIEW SECTION
--
-- Extract views
-- View columns only 
DECLARE cur_TblCol CURSOR FOR 
SELECT 
	o.id oid, o.xtype otype, o.name oname
FROM sysobjects o 
WHERE o.uid = USER_ID(@schema_owner)
AND o.xtype = 'V'
AND OBJECTPROPERTY (o.id, 'IsMSShipped') = 0
ORDER BY o.name

SET @pretableid = -1
OPEN cur_TblCol 
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 RETURN 1

FETCH cur_TblCol INTO @oid,@otype, @oname

WHILE @@FETCH_STATUS <> -1
BEGIN
	-- add view SQL statement here
	SET @linetext = ''

	DECLARE cur_view CURSOR FOR 
	SELECT text
	FROM syscomments sc
	WHERE sc.id = @oid
	ORDER BY colid

	OPEN cur_view 
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 RETURN 1

	FETCH cur_view INTO @linetext

	WHILE @@FETCH_STATUS <> -1
	BEGIN
		INSERT INTO t_sys_schema (line_text) VALUES (@linetext)

		FETCH cur_view INTO @linetext
	END -- while view text
	CLOSE cur_view 
	DEALLOCATE cur_view 
	INSERT INTO t_sys_schema (line_text) VALUES ('GO')

FETCH cur_TblCol INTO @oid,@otype, @oname
END -- view column while loop
CLOSE cur_TblCol 
DEALLOCATE cur_TblCol 

--
-- FOREIGN KEY SECTION
--
-- Extract foreign keys
SELECT
	r.rkeyid,
	r.rkey1, r.rkey2, r.rkey3, r.rkey4, r.rkey5, r.rkey6, r.rkey7, r.rkey8,
	r.rkey9, r.rkey10, r.rkey11, r.rkey12, r.rkey13, r.rkey14, r.rkey15, r.rkey16,
	r.fkeyid,
	r.fkey1, r.fkey2, r.fkey3, r.fkey4, r.fkey5, r.fkey6, r.fkey7, r.fkey8,
	r.fkey9, r.fkey10, r.fkey11, r.fkey12, r.fkey13, r.fkey14, r.fkey15, r.fkey16,
	r.constid, o.name constname --, i.name pkname
INTO #fkeyflat
FROM sysreferences r
	INNER JOIN sysobjects o ON o.id = r.constid AND o.xtype = 'F' AND o.uid = USER_ID(@schema_owner)
	INNER JOIN sysindexes i ON i.id = r.rkeyid AND i.indid = r.rkeyindid 

-- convert the flat format to row format
SELECT rkeyid, rkey1 rkeycolid, fkeyid, fkey1 fkeycolid, 1 colno, constid, constname
INTO #fkeyrow
FROM #fkeyflat
WHERE fkey1 <> 0
UNION ALL
SELECT rkeyid, rkey2, fkeyid, fkey2, 2, constid, constname
FROM #fkeyflat
WHERE fkey2 <> 0
UNION ALL
SELECT rkeyid, rkey3, fkeyid, fkey3, 3, constid, constname
FROM #fkeyflat
WHERE fkey3 <> 0
UNION ALL
SELECT rkeyid, rkey4, fkeyid, fkey4, 4, constid, constname
FROM #fkeyflat
WHERE fkey4 <> 0
UNION ALL
SELECT rkeyid, rkey5, fkeyid, fkey5, 5, constid, constname
FROM #fkeyflat
WHERE fkey5 <> 0
UNION ALL
SELECT rkeyid, rkey6, fkeyid, fkey6, 6, constid, constname
FROM #fkeyflat
WHERE fkey6 <> 0
UNION ALL
SELECT rkeyid, rkey7, fkeyid, fkey7, 7, constid, constname
FROM #fkeyflat
WHERE fkey7 <> 0
UNION ALL
SELECT rkeyid, rkey8, fkeyid, fkey8, 8, constid, constname
FROM #fkeyflat
WHERE fkey8 <> 0
UNION ALL
SELECT rkeyid, rkey9, fkeyid, fkey9, 9, constid, constname
FROM #fkeyflat
WHERE fkey9 <> 0
UNION ALL
SELECT rkeyid, rkey10, fkeyid, fkey10, 10, constid, constname
FROM #fkeyflat
WHERE fkey10 <> 0
UNION ALL
SELECT rkeyid, rkey11, fkeyid, fkey11, 11, constid, constname
FROM #fkeyflat
WHERE fkey11 <> 0
UNION ALL
SELECT rkeyid, rkey12, fkeyid, fkey12, 12, constid, constname
FROM #fkeyflat
WHERE fkey12 <> 0
UNION ALL
SELECT rkeyid, rkey13, fkeyid, fkey13, 13, constid, constname
FROM #fkeyflat
WHERE fkey13 <> 0
UNION ALL
SELECT rkeyid, rkey14, fkeyid, fkey14, 14, constid, constname
FROM #fkeyflat
WHERE fkey14 <> 0
UNION ALL
SELECT rkeyid, rkey15, fkeyid, fkey15, 15, constid, constname
FROM #fkeyflat
WHERE fkey15 <> 0
UNION ALL
SELECT rkeyid, rkey16, fkeyid, fkey16, 16, constid, constname
FROM #fkeyflat
WHERE fkey16 <> 0

DECLARE cur_fk CURSOR FOR 
SELECT
	oparent.name parenttbl, cparent.name pcol, ochild.name childtbl, cchild.name ccol, constname
FROM #fkeyrow fk
	INNER JOIN sysobjects oparent ON oparent.id = fk.rkeyid
	INNER JOIN syscolumns cparent ON cparent.id = fk.rkeyid AND cparent.colid = fk.rkeycolid
	INNER JOIN sysobjects ochild ON ochild.id = fk.fkeyid
	INNER JOIN syscolumns cchild ON cchild .id = fk.fkeyid AND cchild .colid = fk.fkeycolid
ORDER BY oparent.id, ochild.id, constname, fk.colno

OPEN cur_fk 
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 RETURN 1

SET @preparenttbl = 'no fk yet'
SET @prechildtbl = ''
SET @preconstname = ''
FETCH cur_fk INTO @parenttbl, @pcol, @childtbl, @ccol, @constname

WHILE @@FETCH_STATUS <> -1
BEGIN
	-- a new FK
	IF RTRIM(@preparenttbl)+RTRIM(@prechildtbl)+RTRIM(@preconstname) <> RTRIM(@parenttbl)+RTRIM(@childtbl)+RTRIM(@constname)
	BEGIN
		-- insert the previous FK
		IF @preparenttbl <> 'no fk yet'
		BEGIN
			INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
			INSERT INTO t_sys_schema (line_text) VALUES (RTRIM(@linetext2)+')')
			INSERT INTO t_sys_schema (line_text) VALUES (RTRIM(@linetext3)+')')
			INSERT INTO t_sys_schema (line_text) VALUES ('GO')
		END

		-- prepare the current FK
		SET @linetext = 'ALTER TABLE ' + RTRIM(@childtbl) + ' ADD CONSTRAINT ' + @constname
		SET @linetext2 = ' FOREIGN KEY (' + @ccol
		SET @linetext3 = ' REFERENCES ' + RTRIM(@parenttbl) + ' (' + @pcol
	END
	ELSE
	-- existing fk
	BEGIN
		-- takes care of the additional FK columns
		SET @linetext2 = RTRIM(@linetext2) + ',' + @ccol
		SET @linetext3 = RTRIM(@linetext3) + ',' + @pcol 
	END

	SET @preparenttbl = @parenttbl
	SET @prechildtbl = @childtbl
	SET @preconstname = @constname

	FETCH cur_fk INTO @parenttbl, @pcol, @childtbl, @ccol, @constname
END -- fk while loop
CLOSE cur_fk 
DEALLOCATE cur_fk 

-- takes care of the last FK
IF @preparenttbl <> 'no fk yet'
BEGIN
	INSERT INTO t_sys_schema (line_text) VALUES (@linetext)
	INSERT INTO t_sys_schema (line_text) VALUES (RTRIM(@linetext2)+')')
	INSERT INTO t_sys_schema (line_text) VALUES (RTRIM(@linetext3)+')')
	INSERT INTO t_sys_schema (line_text) VALUES ('GO')
END

IF @debug_flag = 1 PRINT 'After closing the cursor'

RETURN 0
END
GO
