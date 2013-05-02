
			Create Procedure DeleteAccounts
				@account_id_list nvarchar(4000), --accounts to be deleted
				@table_name nvarchar(4000), --table containing id_acc to be deleted
				@linked_server_name nvarchar(255), --linked server name for payment server
				@payment_server_dbname nvarchar(255) --payment server database name
			AS
			set nocount on
			set xact_abort on
			declare @sql nvarchar(4000)
	/*
			How to run this stored procedure
			exec DeleteAccounts @account_id_list='123,124',@table_name=null,@linked_server_name=null,@payment_server_dbname=null
			or
			exec DeleteAccounts @account_id_list=null,@table_name='tmp_t_account',@linked_server_name=null,@payment_server_dbname=null
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

				if ((@account_id_list is not null and @table_name is not null) or
				(@account_id_list is null and @table_name is null))
				begin
					print 'ERROR--Delete account operation failed-->Either account_id_list or table_name should be specified'
					return -1
				END

				if (@account_id_list is not null)
				begin
					PRINT '-- Parsing Account IDs passed in and inserting in tmp table --'
					WHILE CHARINDEX(',', @account_id_list) > 0
					BEGIN
						INSERT INTO #AccountIDsTable (ID, status, message)
	 					SELECT SUBSTRING(@account_id_list,1,(CHARINDEX(',', @account_id_list)-1)), 1, 'Okay to delete'
	 					SET @account_id_list =
	 						SUBSTRING (@account_id_list, (CHARINDEX(',', @account_id_list)+1),
	  										(LEN(@account_id_list) - (CHARINDEX(',', @account_id_list))))
					END
	 						INSERT INTO #AccountIDsTable (ID, status, message)
							SELECT @account_id_list, 1, 'Okay to delete'
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

					--fix bug 11599
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
							1, ''Okay to delete'' from ' + @table_name
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
				-- SELECT * from #AccountIDsTable

				/*
				-- print out the accounts with their login names
				SELECT
					ID as two,
					nm_login as two
				FROM
					#AccountIDsTable a,
					t_account_mapper b
				WHERE
					a.ID = b.id_acc
				*/

				/*
				 * Check for all the business rules.  We want to make sure
				 * that we are checking the more restrictive rules first
				 * 1. Check for usage in hard closed interval
				 * 2. Check for invoices in hard closed interval
				 * 3. Check if the account is a payer ever
				 * 4. Check if the account is a payee for usage that exists in the system
				 * 5. Check if the account is a receiver of per subscription Recurring
				 *    Charge
				 * 6. Check for usage in soft/open closed interval
				 * 7. Check for invoices in soft/open closed interval
				 * 8. Check if the account contributes to group discount
				 */
				PRINT '-- Account does not exists check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account does not exists!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					not EXISTS (
						SELECT
							1
						FROM
							t_account acc
						WHERE
							acc.id_acc = tmp.ID )

				-- 1. Check for 'hard close' usage in any of these accounts
				PRINT '-- Usage in Hard closed interval check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account contains usage in hard interval!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							au.id_acc
						FROM
							t_acc_usage au INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = au.id_usage_interval AND
							ui.tx_status in ('H') AND
							au.id_acc = ui.id_acc
						WHERE
							au.id_acc = tmp.ID )

				-- 2. Check for invoices in hard closed interval usage in any of these
				-- accounts
				PRINT '-- Invoices in Hard closed interval check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account contains invoices for hard closed interval!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							i.id_acc
						FROM
							t_invoice i INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = i.id_interval AND
							ui.tx_status in ('H')
						WHERE
							i.id_acc = tmp.ID )

				-- 3. Check if this account has ever been a payer
				PRINT '-- Payer check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is a payer!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							p.id_payer
						FROM
							t_payment_redir_history p
						WHERE
							p.id_payer = tmp.ID AND
							p.id_payee not in (select id from #AccountIDsTable))

				-- 4. Check if the account is a payee for usage that exists in the system
				PRINT '-- Payee usage check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is a payee with usage in the system!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT TOP 1 *							
						FROM
							t_acc_usage accU
						WHERE
							accU.id_payee = tmp.ID)		
							
				-- 5. Check if this account is receiver of per subscription RC
				PRINT '-- Receiver of per subscription Recurring Charge check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is receiver of per subscription RC!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							gsrm.id_acc
						FROM
							t_gsub_recur_map gsrm
						WHERE
							gsrm.id_acc = tmp.ID )

				-- 6. Check for invoices in soft closed or open usage in any of these
				-- accounts
				PRINT '-- Invoice in Soft closed/Open interval check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account contains invoices for soft closed interval.  Please backout invoice adapter first!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							i.id_acc
						FROM
							t_invoice i INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = i.id_interval AND
							ui.tx_status in ('C', 'O')
						WHERE
							i.id_acc = tmp.ID )

				-- 7. Check for 'soft close/open' usage in any of these accounts
				PRINT '-- Usage in Soft closed/Open interval check --'
				UPDATE
					tmp
				SET					status = 0, -- failure
					message = 'Account contains usage in soft closed or open interval.  Please backout first!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							au.id_acc
						FROM
							t_acc_usage au INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = au.id_usage_interval AND
							ui.tx_status in ('C', 'O') AND
							au.id_acc = ui.id_acc
						WHERE
							au.id_acc = tmp.ID )

				-- 8. Check if this account contributes to group discount
				PRINT '-- Contribution to Discount Distribution check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is contributing to a discount!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							gs.id_discountAccount
						FROM
							t_group_sub gs
						WHERE
							gs.id_discountAccount = tmp.ID )

				IF EXISTS (
					SELECT
						*
					FROM
						#AccountIDsTable
					WHERE
						status = 0)
				BEGIN					PRINT 'Deletion of accounts cannot proceed. Fix the errors!'
					PRINT '-- Exiting --!'
					SELECT
						*
					FROM
						#AccountIDsTable

					RETURN
				END

				-- Start the deletes here
				PRINT '-- Beginning the transaction here --'
				BEGIN TRANSACTION

				-- Script to find ICB rates and delete from t_pt, t_rsched,
				-- t_pricelist tables
				PRINT '-- Finding ICB rate and deleting for PC tables --'
				create table #id_sub (id_sub int)
				INSERT into #id_sub select id_sub from t_sub where id_acc
				IN (SELECT ID FROM #AccountIDsTable)
				DECLARE @id_pt table (id_pt int,id_pricelist int)
				INSERT
					@id_pt
				SELECT
					id_paramtable,
					id_pricelist
				FROM
					t_pl_map
				WHERE
					id_sub IN (SELECT * FROM #id_sub)
				DECLARE c1 cursor forward_only for select id_pt,id_pricelist from @id_pt
				DECLARE @name varchar(200)
				DECLARE @pt_name varchar(200)
				DECLARE @pl_name varchar(200)
				DECLARE @str varchar(4000)
				OPEN c1
				FETCH c1 INTO @pt_name,@pl_name
				SELECT
					@name =
				REVERSE(substring(REVERSE(nm_name),1,charindex('/',REVERSE(nm_name))-1))
				FROM
					t_base_props
				WHERE
					id_prop = @pt_name
				SELECT
					@str = 'DELETE t_pt_' + @name + ' from t_pt_' + @name + ' INNER JOIN t_rsched rsc on t_pt_'
						+ @name + '.id_sched = rsc.id_sched
						INNER JOIN t_pl_map map ON
						map.id_paramtable = rsc.id_pt AND
						map.id_pi_template = rsc.id_pi_template AND
						map.id_pricelist = rsc.id_pricelist
						WHERE map.id_sub IN (SELECT id_sub FROM #id_sub)'
				EXECUTE (@str)
				SELECT @str = 'DELETE FROM t_rsched WHERE id_pricelist =' + @pl_name
				EXECUTE (@str)
				SELECT @str = 'DELETE FROM t_pl_map WHERE id_pricelist =' + @pl_name
				EXECUTE (@str)
				SELECT @str = 'DELETE FROM t_pricelist WHERE id_pricelist =' + @pl_name
				EXECUTE (@str)

				CLOSE c1
				DEALLOCATE c1

				-- t_billgroup_member
				PRINT '-- Deleting from t_billgroup_member --'
				DELETE FROM t_billgroup_member
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_member table'
					GOTO SetError
				END

				-- t_billgroup_member_history
				PRINT '-- Deleting from t_billgroup_member_history --'
				DELETE FROM t_billgroup_member_history
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_member_history table'
					GOTO SetError
				END

				-- t_billgroup_member_history
				PRINT '-- Deleting from t_billgroup_source_acc --'
				DELETE FROM t_billgroup_source_acc
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_source_acc table'
					GOTO SetError
				END

				-- t_billgroup_constraint
				PRINT '-- Deleting from t_billgroup_constraint  --'
				DELETE FROM t_billgroup_constraint
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_constraint table'
					GOTO SetError
				END

				-- t_billgroup_constraint_tmp
				PRINT '-- Deleting from t_billgroup_constraint_tmp --'
				DELETE FROM t_billgroup_constraint_tmp
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_constraint_tmp table'
					GOTO SetError
				END

				-- t_av_* tables
				DECLARE @t_av_table_name nvarchar(1000)
				DECLARE c2 CURSOR FOR SELECT table_name FROM information_schema.tables
				WHERE table_name LIKE 't_av_%' AND table_type = 'BASE TABLE'
				-- Delete from t_av_* tables
				OPEN c2
				FETCH NEXT FROM c2 into @t_av_table_name
				WHILE (@@FETCH_STATUS = 0)
				BEGIN
					PRINT '-- Deleting from ' + @t_av_table_name + ' --'
					EXEC ('DELETE FROM ' + @t_av_table_name + ' WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)')
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from ' + @t_av_table_name + ' table'
  						CLOSE c2
   						DEALLOCATE c2
						GOTO SetError
					END
   					FETCH NEXT FROM c2 INTO @t_av_table_name
				END
  				CLOSE c2
   				DEALLOCATE c2

				-- t_account_state_history
				PRINT '-- Deleting from t_account_state_history --'
				DELETE FROM t_account_state_history
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_state_history table'
					GOTO SetError
				END

				-- t_account_state
				PRINT '-- Deleting from t_account_state --'
				DELETE FROM t_account_state
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_state table'
					GOTO SetError
				END

				-- t_acc_usage_interval
				PRINT '-- Deleting from t_acc_usage_interval --'
				DELETE FROM t_acc_usage_interval
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_usage_interval table'
					GOTO SetError
				END

				-- t_acc_usage_cycle
				PRINT '-- Deleting from t_acc_usage_cycle --'
				DELETE FROM t_acc_usage_cycle
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_usage_cycle table'
					GOTO SetError
				END

				-- t_acc_template_props
				PRINT '-- Deleting from t_acc_template_props --'
				DELETE FROM t_acc_template_props
				WHERE id_acc_template IN
				(SELECT id_acc_template
				FROM t_acc_template
				WHERE id_folder in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_template_props table'
					GOTO SetError
				END

				-- t_acc_template_subs
				PRINT '-- Deleting from t_acc_template_subs --'
				DELETE FROM t_acc_template_subs
				WHERE id_acc_template IN
				(SELECT id_acc_template
				FROM t_acc_template
				WHERE id_folder in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_template_subs table'
					GOTO SetError
				END

				-- t_acc_template
				PRINT '-- Deleting from t_acc_template --'
				DELETE FROM t_acc_template
				WHERE id_folder in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_template table'
					GOTO SetError
				END

				-- t_user_credentials
				PRINT '-- Deleting from t_user_credentials --'
				DELETE FROM t_user_credentials
				WHERE nm_login IN
				(SELECT nm_login
				FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_user_credentials table'
					GOTO SetError
				END

				-- t_profile
				PRINT '-- Deleting from t_profile --'
				DELETE FROM t_profile
				WHERE id_profile IN
				(SELECT id_profile
				FROM t_site_user
				WHERE nm_login IN
				(SELECT nm_login
				FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_profile table'
					GOTO SetError
				END

				-- t_site_user
				PRINT '-- Deleting from t_site_user --'
				DELETE FROM t_site_user
				WHERE nm_login IN
				(SELECT nm_login
				FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_site_user table'
					GOTO SetError
				END

				-- t_payment_redirection
				PRINT '-- Deleting from t_payment_redirection --'
				DELETE FROM t_payment_redirection
				WHERE id_payee IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_payment_redirection table'
					GOTO SetError
				END

				-- t_payment_redir_history
				PRINT '-- Deleting from t_payment_redir_history --'
				DELETE FROM t_payment_redir_history
				WHERE id_payee IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_payment_redir_history table'
					GOTO SetError
				END

				-- t_sub
				PRINT '-- Deleting from t_sub --'
				DELETE FROM t_sub
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_sub table'
					GOTO SetError
				END

				-- t_sub_history
				PRINT '-- Deleting from t_sub_history --'
				DELETE FROM t_sub_history
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_sub_history table'
					GOTO SetError
				END

				-- t_group_sub
				PRINT '-- Deleting from t_group_sub --'
				DELETE FROM t_group_sub
				WHERE id_discountAccount in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_group_sub table'
					GOTO SetError
				END

				-- t_gsubmember
				PRINT '-- Deleting from t_gsubmember --'
				DELETE FROM t_gsubmember
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_gsubmember table'
					GOTO SetError
				END

				-- t_gsubmember_historical
				PRINT '-- Deleting from t_gsubmember_historical --'
				DELETE FROM t_gsubmember_historical
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_gsubmember_historical table'
					GOTO SetError
				END

				-- t_gsub_recur_map
				PRINT '-- Deleting from t_gsub_recur_map --'
				DELETE FROM t_gsub_recur_map
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
				  PRINT 'Cannot delete from t_gsub_recur_map table'
					GOTO SetError
				END

				-- t_pl_map
				PRINT '-- Deleting from t_pl_map --'
				DELETE FROM t_pl_map
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_pl_map table'
					GOTO SetError
				END

				-- t_path_capability
				PRINT '-- Deleting from t_path_capability --'
				DELETE FROM t_path_capability
				WHERE id_cap_instance IN (
				SELECT id_cap_instance FROM t_capability_instance ci
				WHERE ci.id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_path_capability table'
					GOTO SetError
				END

				-- t_enum_capability
				PRINT '-- Deleting from t_enum_capability --'
				DELETE FROM t_enum_capability
				WHERE id_cap_instance IN (
				SELECT id_cap_instance FROM t_capability_instance ci
				WHERE ci.id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_enum_capability table'
					GOTO SetError
				END

				-- t_decimal_capability
				PRINT '-- Deleting from t_decimal_capability --'
				DELETE FROM t_decimal_capability
				WHERE id_cap_instance IN (
				SELECT id_cap_instance FROM t_capability_instance ci
				WHERE ci.id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_decimal_capability table'
					GOTO SetError
				END

				-- t_capability_instance
				PRINT '-- Deleting from t_capability_instance --'
				DELETE FROM t_capability_instance
				WHERE id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_capability_instance table'
					GOTO SetError
				END

				-- t_policy_role
				PRINT '-- Deleting from t_policy_role --'
				DELETE FROM t_policy_role
				WHERE id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_policy_role table'
					GOTO SetError
				END

				-- t_principal_policy
				PRINT '-- Deleting from t_principal_policy --'
				DELETE FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_principal_policy table'
					GOTO SetError
				END

				-- t_impersonate
				PRINT '-- Deleting from t_impersonate --'
				DELETE FROM t_impersonate
				WHERE (id_acc in (SELECT ID FROM #AccountIDsTable)
				or id_owner in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_impersonate table'
					GOTO SetError
				END

				-- t_account_mapper
				PRINT '-- Deleting from t_account_mapper --'
				DELETE FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_mapper table'
					GOTO SetError
				END

				DECLARE @hierarchyrule nvarchar(10)
				SELECT @hierarchyrule = value
				FROM t_db_values
				WHERE parameter = 'Hierarchy_RestrictedOperations'
				IF (@hierarchyrule = 'True')
				BEGIN
				  DELETE FROM t_group_sub
					WHERE id_corporate_account IN (SELECT ID FROM #AccountIDsTable)
					IF (@@Error <> 0)
					BEGIN
					  PRINT 'Cannot delete from t_group_sub table'
						GOTO SetError
					END
				END

				-- t_account_ancestor
				PRINT '-- Deleting from t_account_ancestor --'
				DELETE FROM t_account_ancestor
				WHERE id_descendent in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_ancestor table'
					GOTO SetError
				END

				UPDATE
					t_account_ancestor
				SET
					b_Children = 'N'
				FROM
					t_account_ancestor aa1
				WHERE
					id_descendent IN (SELECT ID FROM #AccountIDsTable) and
					NOT EXISTS (SELECT 1 FROM t_account_ancestor aa2
											WHERE aa2.id_ancestor = aa1.id_descendent
											AND num_generations <> 0)

				-- t_account
				PRINT '-- Deleting from t_account --'
				DELETE FROM t_account
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account table'
					GOTO SetError
				END

				PRINT '-- Deleting from t_dm_account_ancestor --'
				DELETE FROM t_dm_account_ancestor
				WHERE id_dm_descendent in
				(
				select id_dm_acc from t_dm_account where id_acc in
				(SELECT ID FROM #AccountIDsTable)
				)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_dm_account_ancestor table'
					GOTO SetError
				END

				PRINT '-- Deleting from t_dm_account --'
				DELETE FROM t_dm_account
				WHERE id_acc in
				(SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_dm_account table'
					GOTO SetError
				END

				-- IF (@linked_server_name <> NULL)
				-- BEGIN
				  -- Do payment server stuff here
				-- END

				-- If we are here, then all accounts should have been deleted

				if (@linked_server_name is not NULL and @payment_server_dbname is not null)
				begin
					select @sql = 'delete from ' + @linked_server_name + '.' + @payment_server_dbname + '.dbo.t_ps_creditcard WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					print (@sql)
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_creditcard table'
						GOTO SetError
					end
					select @sql = 'delete from ' + @linked_server_name + '.' + @payment_server_dbname + '.dbo.t_ps_ach WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_ach table'
						GOTO SetError
					END
				end
				if (@linked_server_name is NULL and @payment_server_dbname is not null)
				begin
					select @sql = 'delete from ' + @payment_server_dbname + '.dbo.t_ps_creditcard WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_creditcard table'
						GOTO SetError
					end
					select @sql = 'delete from ' + @payment_server_dbname + '.dbo.t_ps_ach WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_ach table'
						GOTO SetError
					END
				end

				if (@linked_server_name is not NULL and @payment_server_dbname is null)
					BEGIN
						PRINT 'Please specify the database name of payment server'
						GOTO SetError
					END

				UPDATE
				  #AccountIDsTable
				SET
				  message = 'This account no longer exists!'

				SELECT
					*
				FROM
					#AccountIDsTable
				--WHERE
				--	status <> 0

				COMMIT TRANSACTION
				RETURN 0

				SetError:
					ROLLBACK TRANSACTION
					RETURN -1
			