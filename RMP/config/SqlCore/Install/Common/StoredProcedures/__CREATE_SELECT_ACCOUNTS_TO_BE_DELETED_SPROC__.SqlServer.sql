
			CREATE PROC SelectAccountsToBeDeleted
				@accountIDList varchar(4000),
				@tablename nvarchar(4000)
			AS
			set nocount on
			declare @sql nvarchar(4000)
	/*
			How to run this stored procedure
			exec SelectAccountsToBeDeleted @accountIDList='123,124',@tablename=null
			or
			exec SelectAccountsToBeDeleted @accountIDList=null,@tablename='tmp_t_account'
	*/
				-- Break down into simple account IDs
				-- This block of SQL can be used as an example to get
				-- the account IDs from the list of account IDs that are
				-- passed in
				CREATE TABLE #AccountIDsTable (
				  ID int NOT NULL,
					status int NULL,
					message varchar(255) NULL)

				PRINT '------------------------------------------------'
				PRINT '-- Start of Account Deletion Stored Procedure --'
				PRINT '------------------------------------------------'

				if ((@accountIDList is not null and @tablename is not null) or
				(@accountIDList is null and @tablename is null))
				begin
					print 'ERROR--Delete account operation failed-->Either accountIDList or tablename should be specified'
					return -1
				END

				if (@accountIDList is not null)
				begin
					PRINT '-- Parsing Account IDs passed in and inserting in tmp table --'
					WHILE CHARINDEX(',', @accountIDList) > 0
					BEGIN
						INSERT INTO #AccountIDsTable (ID, status, message)
	 					SELECT SUBSTRING(@accountIDList,1,(CHARINDEX(',', @accountIDList)-1)), 1, 'Okay to delete'
	 					SET @accountIDList =
	 						SUBSTRING (@accountIDList, (CHARINDEX(',', @accountIDList)+1),
	  										(LEN(@accountIDList) - (CHARINDEX(',', @accountIDList))))
					END
	 						INSERT INTO #AccountIDsTable (ID, status, message)
							SELECT @accountIDList, 1, 'Okay to delete'
					-- SELECT ID as one FROM #AccountIDsTable

					-- Transitive Closure (check for folder/corporation)
					PRINT '-- Inserting children (if any) into the tmp table --'
					INSERT INTO #AccountIDsTable (ID, status, message)
					SELECT DISTINCT
					  aa.id_descendent,
						1,
						'Okay to delete'
					FROM
					  t_account_ancestor aa INNER JOIN #AccountIDsTable tmp ON
						tmp.ID = aa.id_ancestor AND
						aa.num_generations > 0 AND
					NOT EXISTS (
					  SELECT
						  ID
						FROM
						  #AccountIDsTable tmp1
						WHERE
						  tmp1.ID = aa.id_descendent)

					INSERT INTO #AccountIDsTable (ID, status, message)
					SELECT DISTINCT
					  aa.id_descendent,
						1,
						'Okay to delete'
					FROM
					  t_account_ancestor aa where id_ancestor in (select id from  #AccountIDsTable)
						AND
						aa.num_generations > 0 AND
					NOT EXISTS (
					  SELECT
						  ID
						FROM
						  #AccountIDsTable tmp1
						WHERE
						  tmp1.ID = aa.id_descendent)
				end
				else
				begin
					set @sql = 'INSERT INTO #AccountIDsTable (ID, status, message) SELECT id_acc,
							1, ''Okay to delete'' from ' + @tablename
					exec (@sql)
					INSERT INTO #AccountIDsTable (ID, status, message)
					SELECT DISTINCT
					  aa.id_descendent,
						1,
						'Okay to delete'
					FROM
					  t_account_ancestor aa INNER JOIN #AccountIDsTable tmp ON
						tmp.ID = aa.id_ancestor AND
						aa.num_generations > 0 AND
					NOT EXISTS (
					  SELECT
						  ID
						FROM
						  #AccountIDsTable tmp1
						WHERE
						  tmp1.ID = aa.id_descendent)
				end
				PRINT '-- Account does not exists check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account does not exists!'
				FROM
					#AccountIDsTable tmp
				WHERE
					not EXISTS (
						SELECT
							1
						FROM
							t_account acc
						WHERE
							acc.id_acc = tmp.ID )

				-- SELECT * from #AccountIDsTable

				-- Print out the accounts with their login names
				SELECT
					ID as accountID,
					nm_login as LoginName,
					message
				FROM
					#AccountIDsTable a left outer join
					t_account_mapper b
				on
					a.ID = b.id_acc
			