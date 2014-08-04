
CREATE PROCEDURE apply_subscriptions (
   @template_id                int,
   @sub_start                  datetime,
   @sub_end                    datetime,
   @next_cycle_after_startdate char, /* Y or N */
   @next_cycle_after_enddate   char, /* Y or N */
   @user_id                    int,
   @id_audit                   int,
   @id_event_success           int,
   @id_event_failure           int,
   @systemdate                 datetime,
   @id_template_session        int,
   @retrycount                 int,
   @doCommit				   char = 'Y' /* Y or N */
)
AS
	SET NOCOUNT ON
	DECLARE @my_id_audit         int
	DECLARE @my_error            nvarchar(1024)
	DECLARE @detailtypesubs      int
	DECLARE @detailresultfailure int
	
	SELECT @my_id_audit = @id_audit
	IF @my_id_audit IS NULL
	BEGIN
		DECLARE @audit_msg       nvarchar(256)
		DECLARE @dt_timestamp    datetime
		SET @audit_msg = N'Apply subscriptions from template ' + CAST(@template_id AS nvarchar)
		SET @dt_timestamp = GETDATE()
		EXEC GetCurrentID 'id_audit', @my_id_audit OUT
		EXEC insertauditevent
			@id_userid           = NULL,
			@id_event            = 1451,
			@id_entity_type      = 2,
			@id_entity           = @template_id,
			@dt_timestamp        = @dt_timestamp,
			@id_audit            = @my_id_audit,
			@tx_details          = @audit_msg,
			@tx_logged_in_as     = NULL,
			@tx_application_name = NULL
	END

	SELECT @detailtypesubs = id_enum_data
	FROM   t_enum_data
	WHERE  nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription'
		 
	SELECT @detailresultfailure = id_enum_data
	FROM  t_enum_data
	WHERE  nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure'
  
	IF object_id('tempdb..#t_acc_template_valid_subs') IS NOT NULL
		DROP TABLE #t_acc_template_valid_subs
	
	CREATE TABLE #t_acc_template_valid_subs
	(
		id_po     int,
		id_group  int,
		sub_start datetime,
		sub_end   datetime,
		po_start  datetime,
		po_end    datetime
	)

	CREATE TABLE #tmp_gsubmember
	(
		id_group int,
		id_acc int,
		vt_start datetime,
		vt_end datetime
	)

	CREATE TABLE #tmp_sub
	(
		id_sub	int,
		id_sub_ext	varbinary(16),
		id_acc	int,
		id_po	int,
		dt_crt	datetime,
		vt_start	datetime,
		vt_end	datetime,
		id_group	int
	)

	create index #t_acc_template_valid_subs_ix1 on #t_acc_template_valid_subs(id_po)
	create index #t_acc_template_valid_subs_ix2 on #t_acc_template_valid_subs(id_group)
  
	/* Detect conflicting subscriptions in the template and choice first available of them and without conflicts */
	INSERT INTO #t_acc_template_valid_subs (id_po, id_group, sub_start, sub_end, po_start, po_end)
	SELECT DISTINCT
	       subs.id_po,
		   subs.id_group,
		   subs.sub_start,
		   subs.sub_end,
		   subs.sub_start,
		   subs.sub_end
	FROM
	(
		SELECT t1.id_po
				, MAX(t1.id_group) AS id_group
				, dbo.GreatestDate(t1.vt_start, MAX(ed.dt_start)) AS sub_start
				, dbo.LeastDate(t1.vt_end,ISNULL(MAX(ed.dt_end), dbo.MTMaxDate())) AS sub_end
			FROM (
				SELECT ISNULL(ts.id_po,s.id_po) AS id_po, ts.vt_start, ts.vt_end, s.id_group
					FROM t_acc_template_subs ts
					LEFT JOIN t_sub s ON s.id_group = ts.id_group
					WHERE ts.id_acc_template = @template_id
			) t1
			JOIN t_po po ON po.id_po = t1.id_po
			JOIN t_effectivedate ed ON po.id_eff_date = ed.id_eff_date
			GROUP BY t1.id_po,t1.vt_start,t1.vt_end

/*
		SELECT MAX(ts.id_po) AS id_po, NULL AS id_group, ISNULL(MAX(ed.dt_start), @systemdate) AS sub_start, ISNULL(MAX(ed.dt_end), dbo.MTMaxDate()) AS sub_end
		FROM   t_acc_template_subs ts
			   JOIN t_pl_map pm ON pm.id_po = ts.id_po
			   JOIN t_po po ON ts.id_po = po.id_po
			   JOIN t_effectivedate ed ON po.id_eff_date = ed.id_eff_date
		WHERE  ts.id_acc_template = @template_id
		GROUP BY pm.id_pi_template
		UNION ALL
		SELECT NULL AS id_po, MAX(ts.id_group) AS id_group, ISNULL(MAX(ed.dt_start), @systemdate) AS sub_start, ISNULL(MAX(ed.dt_end), dbo.MTMaxDate()) AS sub_end
		FROM   t_acc_template_subs ts
			   JOIN t_sub s ON s.id_group = ts.id_group
			   JOIN t_pl_map pm ON pm.id_po = s.id_po
			   JOIN t_po po ON po.id_po = s.id_po
			   JOIN t_effectivedate ed ON po.id_eff_date = ed.id_eff_date
		WHERE  ts.id_acc_template = @template_id
		GROUP BY pm.id_pi_template
*/
	) subs

	DECLARE @id_acc  int
	DECLARE accounts CURSOR LOCAL FOR
		SELECT id_descendent AS id_acc
		FROM   t_vw_get_accounts_by_tmpl_id v
		WHERE  v.id_template = @template_id

	OPEN accounts
	FETCH NEXT FROM accounts INTO @id_acc

	/* Applying subscriptions to accounts */
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC apply_subscriptions_to_acc
			@id_acc                     = @id_acc,
			@id_acc_template            = @template_id,
			@next_cycle_after_startdate = @next_cycle_after_startdate,
			@next_cycle_after_enddate   = @next_cycle_after_enddate,
			@user_id                    = @user_id,
			@id_audit                   = @my_id_audit,
			@id_event_success           = @id_event_success,
			@systemdate                 = @systemdate,
			@id_template_session        = @id_template_session,
			@retrycount                 = @retrycount,
			@detailtypesubs             = @detailtypesubs,
			@detailresultfailure        = @detailresultfailure
		
		FETCH NEXT FROM accounts INTO @id_acc
	END
	
	CLOSE accounts
	DEALLOCATE accounts

	DECLARE @maxdate datetime
	SELECT @maxdate = dbo.MTMaxDate()

	IF @doCommit = 'Y' BEGIN
		BEGIN TRAN t2
	END

	BEGIN TRY
		/* Persist the data in transaction */

		INSERT INTO t_gsubmember_historical (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
		SELECT id_group, id_acc, vt_start, vt_end, @systemdate, @maxdate
		FROM   #tmp_gsubmember

		INSERT INTO t_gsubmember(id_group, id_acc, vt_start, vt_end)
		SELECT id_group, id_acc, vt_start, vt_end
		FROM   #tmp_gsubmember

		INSERT INTO t_sub_history
			  (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end, tt_start, tt_end)
		SELECT id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end, @systemdate, @maxdate
		FROM   #tmp_sub

		INSERT INTO t_sub (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end)
		SELECT id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end
		FROM   #tmp_sub

		INSERT INTO t_audit_details (id_audit, tx_details)
		SELECT @my_id_audit,
			   N'Added subscription to id_groupsub ' + CAST(id_group AS nvarchar(10)) +
			   N' for account ' + CAST(id_acc AS nvarchar(10)) +
			   N' from ' + CAST(vt_start AS nvarchar(20)) +
			   N' to ' + CAST(vt_end AS nvarchar(20)) +
			   N' on ' + CAST(@systemdate AS nvarchar(20))
		FROM   #tmp_gsubmember
		UNION ALL
		SELECT @my_id_audit,
			   N'Added subscription to product offering ' + CAST(id_po AS nvarchar(10)) +
			   N' for account ' + CAST(id_acc AS nvarchar) +
			   N' from ' + CAST(vt_start AS nvarchar(20)) +
			   N' to ' + CAST(vt_end AS nvarchar(20)) +
			   N' on ' + CAST(@systemdate AS nvarchar(20))
		FROM   #tmp_sub

		IF @doCommit = 'Y' BEGIN
			COMMIT
		END
	END TRY
	BEGIN CATCH
		-- we should log this.
		IF @doCommit = 'Y' BEGIN
			ROLLBACK
		END
		 
		SELECT @my_error = substring(error_message(), 1, 1024)

		IF @my_id_audit IS NULL
		BEGIN
			IF @id_audit IS NOT NULL
			BEGIN
				SELECT @my_id_audit = @id_audit
			END
			ELSE
			BEGIN
				EXEC getcurrentid 'id_audit', @my_id_audit OUT

				INSERT INTO t_audit (
					id_audit,
					id_event,
					id_userid,
					id_entitytype,
					id_entity,
					dt_crt
					)
				VALUES (
					@my_id_audit,
					@id_event_failure,
					@user_id,
					1,
					@id_acc,
					getutcdate ()
					)
			END
		END

		INSERT INTO t_audit_details (
			id_audit,
			tx_details
			)
		VALUES (
			@my_id_audit,
			'Error applying template to id_acc: ' + CAST(@id_acc AS nvarchar(10)) + ': ' + @my_error
			)
	END CATCH

	DROP TABLE #t_acc_template_valid_subs
	DROP TABLE #tmp_gsubmember
	DROP TABLE #tmp_sub