
CREATE PROCEDURE apply_subscriptions_to_acc (
    @id_acc                     int,
    @id_acc_template            int,
    @next_cycle_after_startdate char, /* Y or N */
    @next_cycle_after_enddate   char, /* Y or N */
    @user_id                    int,
    @id_audit                   int,
    @id_event_success           int,
    @systemdate                 datetime,
    @id_template_session        int,
    @retrycount                 int,
    @detailtypesubs             int,
    @detailresultfailure        int
)
AS
    SET NOCOUNT ON
    DECLARE @v_vt_start        datetime
    DECLARE @v_vt_end          datetime
    DECLARE @v_acc_start       datetime
    DECLARE @v_sub_end         datetime
    DECLARE @curr_id_sub       int
    DECLARE @my_id_audit       int
    DECLARE @my_user_id        int
	DECLARE @id_acc_type       int

    SELECT @my_user_id = ISNULL(@user_id, 1), @my_id_audit = @id_audit
	SELECT @id_acc_type = id_type FROM t_account WHERE id_acc = @id_acc

    IF @my_id_audit IS NULL
    BEGIN
        EXEC getcurrentid 'id_audit', @my_id_audit OUT

        INSERT INTO t_audit
                    (id_audit, id_event, id_userid, id_entitytype, id_entity, dt_crt
                    )
            VALUES (@my_id_audit, @id_event_success, @user_id, 1, @id_acc, getutcdate ()
                    )
    END

    SELECT @v_acc_start = vt_start
    FROM   t_account_state
    WHERE  id_acc = @id_acc
    
    DECLARE @id_po            int
    DECLARE @id_group         int
    DECLARE @vt_start         datetime
    DECLARE @vt_end           datetime
    DECLARE @conflicts        int
    DECLARE @my_sub_start     datetime
    DECLARE @my_sub_end       datetime
    
    DECLARE subs CURSOR LOCAL FOR
		SELECT  id_po,
				id_group,
				dbo.GreatestDate(t1.v_sub_start, @v_acc_start) AS vt_start,
				t1.v_sub_end,
				dbo.GreatestDate(t1.v_sub_start, @v_acc_start) AS v_sub_start,
				t1.v_sub_end
			FROM (
				SELECT
					id_po,
					id_group,
					CASE
						WHEN @next_cycle_after_startdate = 'Y'
						THEN
							(
								SELECT dbo.GreatestDate(DATEADD(s, 1, tpc.dt_end), tvs.po_start)
									FROM   t_pc_interval tpc
									INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
									WHERE  tauc.id_acc = @id_acc
									AND tvs.sub_start BETWEEN tpc.dt_start AND tpc.dt_end
							)
						ELSE tvs.sub_start
					END AS v_sub_start,
					CASE
						WHEN @next_cycle_after_enddate = 'Y'
						THEN
							(
								SELECT dbo.LeastDate(dbo.LeastDate(DATEADD(s, 1, tpc.dt_end), dbo.MTMaxDate()), tvs.po_end)
									FROM   t_pc_interval tpc
									INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
									WHERE  tauc.id_acc = @id_acc
									AND tvs.sub_end BETWEEN tpc.dt_start AND tpc.dt_end
							)
						ELSE tvs.sub_end
					END AS v_sub_end
					FROM #t_acc_template_valid_subs tvs
			) t1
--            WHERE tvs.id_acc_template_session = apply_subscriptions_to_acc.id_template_session


    --  SELECT ts.id_po,
    --         ts.id_group,
    --         dbo.GreatestDate(dbo.LeastDate(MIN(s.vt_start), MIN(gm.vt_start)), @v_acc_start) AS vt_start,
    --         dbo.GreatestDate(MAX(s.vt_end), MAX(gm.vt_end)) AS vt_end,
    --         SUM(CASE WHEN s.id_sub IS NULL THEN 0 ELSE 1 END) + SUM(CASE WHEN gm.id_group IS NULL THEN 0 ELSE 1 END) conflicts,
    --         vs.v_sub_start AS my_sub_start,
    --         vs.v_sub_end AS my_sub_end
    --  FROM   t_acc_template_subs ts
    --         JOIN (
    --                SELECT id_po,
    --                       id_group,
    --                        CASE
    --                           WHEN @next_cycle_after_startdate = 'Y'
    --                           THEN
    --                               (
    --                                 SELECT dbo.GreatestDate(DATEADD(s, 1, tpc.dt_end), tvs.po_start)
    --                                 FROM   t_pc_interval tpc
    --                                        INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
    --                                 WHERE  tauc.id_acc = @id_acc
    --                                    AND tvs.sub_start BETWEEN tpc.dt_start AND tpc.dt_end
    --                               )
    --                           ELSE tvs.sub_start
    --                       END AS v_sub_start,
    --                       CASE
    --                           WHEN @next_cycle_after_enddate = 'Y'
    --                           THEN
    --                               (
    --                                 SELECT dbo.LeastDate(dbo.LeastDate(DATEADD(s, 1, tpc.dt_end), dbo.MTMaxDate()), tvs.po_end)
    --                                 FROM   t_pc_interval tpc
    --                                        INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
    --                                 WHERE  tauc.id_acc = @id_acc
    --                                    AND tvs.sub_end BETWEEN tpc.dt_start AND tpc.dt_end
    --                               )
    --                           ELSE tvs.sub_end
    --                       END AS v_sub_end

    --                FROM   #t_acc_template_valid_subs tvs
    --         ) vs ON vs.id_po = ts.id_po OR vs.id_group = ts.id_group
    --         LEFT JOIN t_sub gs ON gs.id_group = ts.id_group
    --         LEFT JOIN t_sub s
    --          ON     s.id_acc = @id_acc
    --             AND s.vt_start <= vs.v_sub_end
    --             AND s.vt_end >= vs.v_sub_start
    --             AND EXISTS (SELECT 1
    --                         FROM   t_pl_map mpo
    --                                JOIN t_pl_map ms ON mpo.id_pi_template = ms.id_pi_template
    --                         WHERE  mpo.id_po = ISNULL(ts.id_po, gs.id_po) AND ms.id_po = s.id_po)
    --         LEFT JOIN t_gsubmember gm
    --          ON     gm.id_acc = @id_acc
    --             AND gm.vt_start <= vs.v_sub_end
    --             AND gm.vt_end >= vs.v_sub_start
    --             AND EXISTS (SELECT 1
    --                         FROM   t_sub ags
    --                                JOIN t_pl_map ms ON ms.id_po = ags.id_po
    --                                JOIN t_pl_map mpo ON mpo.id_pi_template = ms.id_pi_template
    --                         WHERE  ags.id_group = gm.id_group AND mpo.id_po = ISNULL(ts.id_po, gs.id_po))
    --  WHERE  ts.id_acc_template = @id_acc_template
	   --  /* Check if the PO is available for the account's type */
	   --  AND (  (ts.id_po IS NOT NULL AND
		  --        (  EXISTS
		  --           (
				--        SELECT 1
				--	    FROM   t_po_account_type_map atm
				--	    WHERE  atm.id_po = ts.id_po AND atm.id_account_type = @id_acc_type
				--     )
				--  OR NOT EXISTS
				--     (
				--	     SELECT 1 FROM t_po_account_type_map atm WHERE atm.id_po = ts.id_po
				--	 )
				-- )
				--)
		  --   OR (ts.id_group IS NOT NULL AND
			 --     (  EXISTS
			 --        (
				--        SELECT 1
				--	    FROM   t_po_account_type_map atm
				--	           JOIN t_sub tgs ON tgs.id_po = atm.id_po
				--	    WHERE  tgs.id_group = ts.id_group AND atm.id_account_type = @id_acc_type
				--     )
				-- OR NOT EXISTS
				--     (
				--		SELECT 1
				--	    FROM   t_po_account_type_map atm
				--	           JOIN t_sub tgs ON tgs.id_po = atm.id_po
				--	    WHERE  tgs.id_group = ts.id_group
				--	 )
				--  )
				--)
		  --   )
    --  GROUP BY ts.id_po, ts.id_group, vs.v_sub_start, vs.v_sub_end
	DECLARE @v_prev_end DATETIME
	DECLARE @c_vt_start DATETIME
	DECLARE @c_vt_end DATETIME
    
    OPEN subs
    FETCH NEXT FROM subs INTO @id_po, @id_group, @vt_start, @vt_end, @my_sub_start, @my_sub_end

    /* Create new subscriptions */
    WHILE @@FETCH_STATUS = 0
    BEGIN
		SET @v_prev_end = DATEADD(d, -1, @my_sub_start)
		IF @id_group IS NULL 
		BEGIN 
			DECLARE csubs CURSOR FOR
				SELECT s.vt_start, s.vt_end
					FROM (
						SELECT ts.vt_start
								,ts.vt_end
							FROM t_sub ts
							WHERE ts.vt_end >= @my_sub_start
								AND ts.vt_start <= @my_sub_end
								AND ts.id_acc = @id_acc
								AND ts.id_po = @id_po
						UNION ALL
						SELECT ts1.vt_start
								,ts1.vt_end
							FROM #tmp_sub ts1
							WHERE ts1.vt_end >= @my_sub_start
								AND ts1.vt_start <= @my_sub_end
								AND ts1.id_acc = @id_acc
								AND ts1.id_po = @id_po
					) s
					ORDER BY s.vt_start
		END ELSE BEGIN
			DECLARE csubs CURSOR FOR
				SELECT s.vt_start, s.vt_end
					FROM (
						SELECT ts.vt_start
								,ts.vt_end
							FROM t_gsubmember ts
							WHERE ts.vt_end >= @my_sub_start
								AND ts.vt_start <= @my_sub_end
								AND ts.id_acc = @id_acc
								AND ts.id_group = @id_group
						UNION ALL
						SELECT ts1.vt_start
								,ts1.vt_end
							FROM #tmp_gsubmember ts1
							WHERE ts1.vt_end >= @my_sub_start
								AND ts1.vt_start <= @my_sub_end
								AND ts1.id_acc = @id_acc
								AND ts1.id_group = @id_group
					) s
					ORDER BY s.vt_start
		END

		OPEN csubs
		FETCH NEXT FROM csubs INTO @c_vt_start, @c_vt_end

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @c_vt_start > @v_prev_end
			BEGIN
				SET @v_vt_start = DATEADD(d, 1, @v_prev_end)
				SET @v_vt_end = DATEADD(d, -1, @c_vt_start)
			END
			IF @v_vt_start <= @v_vt_end
			BEGIN
				EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
			END
			SET @v_prev_end = @c_vt_end

			FETCH NEXT FROM csubs INTO @c_vt_start, @c_vt_end
		END
		CLOSE csubs
		DEALLOCATE csubs
		IF @v_prev_end < @my_sub_end
		BEGIN
			SET @v_vt_start = DATEADD(d,1,@v_prev_end)
			SET @v_vt_end = @my_sub_end
				EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
		END

        --/* 1.  There is no conflicting subscription */
        --IF @conflicts = 0
        --BEGIN
        --    SELECT @v_vt_start = @my_sub_start, @v_vt_end = @my_sub_end
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END
        --/* 2.  There is a conflicting subscription for the same or greatest interval */
        --ELSE IF @my_sub_start >= @vt_start AND @my_sub_end <= @vt_end
        --BEGIN
        --    INSERT INTO t_acc_template_session_detail
        --        (
        --            id_session,
        --            n_detail_type,
        --            n_result,
        --            dt_detail,
        --            nm_text,
        --            n_retry_count
        --        )
        --    VALUES
        --        (
        --            @id_template_session,
        --            @detailtypesubs,
        --            @detailresultfailure,
        --            getdate(),
        --            N'Subscription for account ' + CAST(@id_acc AS nvarchar(10)) + N' not created due to ' + CAST(@conflicts AS nvarchar(10)) + N'conflict' + CASE WHEN @conflicts > 1 THEN 's' ELSE '' END,
        --            @retrycount
        --        )
        --END
        --/* 3.  There is a conflicting subscription for an early period */
        --ELSE IF @my_sub_start >= @vt_start AND @my_sub_end > @vt_end
        --BEGIN
        --    SELECT @v_vt_start = DATEADD(d, 1, @vt_end), @v_vt_end = @my_sub_end
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END
        --/* 4.  There is a conflicting subscription for a late period */
        --ELSE IF @my_sub_start < @vt_start AND @my_sub_end <= @vt_end
        --BEGIN
        --    SELECT @v_vt_start = @my_sub_start, @v_vt_end = DATEADD(d, -1, @vt_start)
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END
        --/* 5.  There is a conflicting subscription for the period inside the indicated one */
        --ELSE
        --BEGIN
        --    SELECT @v_vt_start = DATEADD(d, 1, @vt_end), @v_vt_end = @my_sub_end
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate

        --    SELECT @v_vt_start = @my_sub_start, @v_vt_end = DATEADD(d, -1, @vt_start)
            
        --    EXEC subscribe_account @id_acc, @id_po, @id_group, @v_vt_start, @v_vt_end, @systemdate
        --END

        FETCH NEXT FROM subs INTO @id_po, @id_group, @vt_start, @vt_end, @my_sub_start, @my_sub_end
    END

    CLOSE subs
    DEALLOCATE subs
