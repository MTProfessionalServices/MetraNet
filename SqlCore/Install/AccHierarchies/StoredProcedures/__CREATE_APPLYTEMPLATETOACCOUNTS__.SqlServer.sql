CREATE PROCEDURE ApplyTemplateToAccounts(
	@idAccountTemplate          int,
	@sub_start                  datetime,
	@sub_end                    datetime,
	@next_cycle_after_startdate char, /* Y or N */
	@next_cycle_after_enddate   char, /* Y or N */
	@user_id                    int,
	@id_event_success           int,
	@id_event_failure           int,
	@systemDate                 datetime,
	@sessionId                  int,
	@retrycount                 int,
	@account_id					int = NULL,
	@doCommit					char = 'Y'
)
as
	SET NOCOUNT ON

	DECLARE @errTbl TABLE (
		dt_detail datetime NOT NULL,
		nm_text nvarchar(4000) NOT NULL
	)

	DELETE FROM @errTbl

	IF @doCommit = 'Y'
	BEGIN
		BEGIN TRANSACTION T1
	END
	BEGIN TRY
		DECLARE @DetailTypeUpdate int
		SELECT @DetailTypeUpdate = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Update'

		DECLARE @DetailResultSuccess int
		DECLARE @DetailResultFailure int
		SELECT @DetailResultFailure = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure'
		SELECT @DetailResultSuccess = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success'

		declare @DetailTypeGeneral int
		declare @DetailResultInformation int
		declare @DetailTypeSubscription int


		SELECT @DetailTypeGeneral = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success'
		SELECT @DetailResultInformation = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information'
		SELECT @DetailTypeSubscription = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription'

		DECLARE @errorStr NVARCHAR(4000)

		EXEC UpdateAccPropsFromTemplate @idAccountTemplate, @account_id

		DECLARE @UsageCycleId INTEGER
		DECLARE @PayerId INTEGER

		SET @UsageCycleId = -1;

		SELECT @UsageCycleId = tuc.id_usage_cycle, @PayerId = tprop.PayerID
			FROM t_usage_cycle tuc
			RIGHT OUTER JOIN (
				SELECT 	tp.DayOfMonth
						,tp.StartDay
						,ISNULL(m.num,-1) StartMonth
						,tuct.id_cycle_type
						,ISNULL(dw.num,-1) DayOfWeek
						,tp.StartYear
						,tp.FirstDayOfMonth
						,tp.SecondDayOfMonth
						,tp.PayerID
					FROM (
						SELECT   MAX(CASE WHEN tatp.nm_prop = N'Account.DayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS DayOfMonth
								,MAX(CASE WHEN tatp.nm_prop = N'Account.DayOfWeek' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS DayOfWeek
								,MAX(CASE WHEN tatp.nm_prop = N'Account.StartDay' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartDay
								,MAX(CASE WHEN tatp.nm_prop = N'Account.StartMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartMonth
								,MAX(CASE WHEN tatp.nm_prop = N'Account.StartYear' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartYear
								,MAX(CASE WHEN tatp.nm_prop = N'Account.FirstDayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS FirstDayOfMonth
								,MAX(CASE WHEN tatp.nm_prop = N'Account.SecondDayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS SecondDayOfMonth
								,MAX(CASE WHEN tatp.nm_prop = N'Internal.UsageCycleType' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS UsageCycleType
								,MAX(CASE WHEN tatp.nm_prop = N'Account.PayerID' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS PayerID
							FROM t_acc_template_props tatp
							WHERE tatp.id_acc_template = @idAccountTemplate
							GROUP BY tatp.id_acc_template
					) tp
					LEFT JOIN t_enum_data tedm ON tedm.id_enum_data = tp.StartMonth
					LEFT JOIN t_enum_data tedc ON tedc.id_enum_data = tp.UsageCycleType
					LEFT JOIN t_enum_data tedw ON tedw.id_enum_data = tp.DayOfWeek
					LEFT JOIN fn_months() m ON tedm.nm_enum_data LIKE '%' + m.name
					LEFT JOIN fn_day_of_week() dw ON tedw.nm_enum_data LIKE '%' + dw.name
					LEFT JOIN t_usage_cycle_type tuct ON UPPER(tuct.tx_desc) LIKE REPLACE(UPPER(SUBSTRING(tedc.nm_enum_data, LEN(tedc.nm_enum_data) - CHARINDEX('/',REVERSE(tedc.nm_enum_data))+2, CHARINDEX('/',REVERSE(tedc.nm_enum_data)))), '-', '%')
			) tprop ON tprop.DayOfMonth = ISNULL(tuc.day_of_month, tprop.DayOfMonth)
			  AND tprop.StartDay = ISNULL(tuc.start_day,tprop.StartDay)
			  AND tprop.StartMonth = ISNULL(tuc.start_month,tprop.StartMonth)
			  AND tprop.DayOfWeek = ISNULL(tuc.day_of_week,tprop.DayOfWeek)
			  AND tprop.StartYear = ISNULL(tuc.start_year,tprop.StartYear)
			  AND tprop.FirstDayOfMonth = ISNULL(tuc.first_day_of_month,tprop.FirstDayOfMonth)
			  AND tprop.SecondDayOfMonth = ISNULL(tuc.second_day_of_month,tprop.SecondDayOfMonth)
			  AND tuc.id_cycle_type = tprop.id_cycle_type

		DECLARE acc CURSOR FOR
		SELECT   ta.id_acc
				,tauc.id_usage_cycle
				,tpr.id_payee
				,tpr.id_payer
				,tpr.vt_start
				,tpr.vt_end
				,tavi.c_Currency
			FROM t_vw_get_accounts_by_tmpl_id va
			JOIN t_account ta ON ta.id_acc = va.id_descendent
			JOIN t_acc_usage_cycle tauc ON tauc.id_acc = ta.id_acc
			LEFT JOIN t_payment_redirection tpr ON tpr.id_payee = ta.id_acc
			LEFT JOIN t_av_Internal tavi ON tavi.id_acc = ta.id_acc
			WHERE va.id_template = @idAccountTemplate
				AND @systemDate BETWEEN COALESCE(va.vt_start, @systemDate) AND COALESCE(va.vt_end, @systemDate)
				AND (
					(@UsageCycleId <> -1 AND tauc.id_usage_cycle <> @UsageCycleId)
					OR (@PayerId <> -1 AND tpr.id_payee <> @PayerId)
				)
				AND ta.id_acc = ISNULL(@account_id, ta.id_acc)


		DECLARE @IdAcc INTEGER
		DECLARE @OldUsageCycle INTEGER
		DECLARE @PayeeId INTEGER
		DECLARE @OldPayerId INTEGER
		DECLARE @PaymentStart DATETIME
		DECLARE @PaymentEnd DATETIME
		DECLARE @p_status INTEGER
		DECLARE @oldpayerstart datetime
		DECLARE @oldpayerend datetime
		DECLARE @oldpayer int
		DECLARE @payerenddate datetime
		DECLARE @p_account_currency NVARCHAR(5)

		OPEN acc

		FETCH NEXT FROM acc INTO @IdAcc, @OldUsageCycle, @PayeeId, @OldPayerId, @PaymentStart, @PaymentEnd, @p_account_currency

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @errorStr = ''
			EXEC dbo.UpdateUsageCycleFromTemplate @IdAcc, @UsageCycleId, @OldUsageCycle, @systemDate, @errorStr OUTPUT
			IF @errorStr <> '' BEGIN
				INSERT INTO @errTbl(dt_detail, nm_text) VALUES(GETDATE(), @errorStr)
			END

			SET @errorStr = ''
			EXEC UpdatePayerFromTemplate
				@IdAcc = @IdAcc,
				@PayerId = @PayerId,
				@systemDate = @systemDate,
				@PaymentStart = @PaymentStart,
				@PaymentEnd = @PaymentEnd,
				@OldPayerId = @OldPayerId,
				@p_account_currency = @p_account_currency,
				@errorStr = @errorStr OUT
			IF @errorStr <> '' BEGIN
				INSERT INTO @errTbl(dt_detail, nm_text) VALUES(GETDATE(), @errorStr)
			END
			SET @errorStr = ''
			FETCH NEXT FROM acc INTO @IdAcc, @OldUsageCycle, @PayeeId, @OldPayerId, @PaymentStart, @PaymentEnd, @p_account_currency
		END
		CLOSE acc
		DEALLOCATE acc
		IF @doCommit = 'Y' BEGIN
			COMMIT TRANSACTION T1
		END
	END TRY
	BEGIN CATCH
		INSERT INTO @errTbl(dt_detail, nm_text) VALUES(GETDATE(), ERROR_MESSAGE())
		IF @doCommit = 'Y' BEGIN
			ROLLBACK TRANSACTION T1
		END
	END CATCH

	EXEC apply_subscriptions
		@template_id                = @idAccountTemplate,
		@sub_start                  = @sub_start,
		@sub_end                    = @sub_end,
		@next_cycle_after_startdate = @next_cycle_after_startdate,
		@next_cycle_after_enddate   = @next_cycle_after_enddate,
		@user_id                    = @user_id,
		@id_audit                   = null,
		@id_event_success           = @id_event_success,
		@id_event_failure           = @id_event_failure,
		@systemdate                 = @systemDate,
		@id_template_session        = @sessionId,
		@retrycount                 = @retrycount

	INSERT INTO t_acc_template_session_detail
	(
		id_session,
		n_detail_type,
		n_result,
		dt_detail,
		nm_text,
		n_retry_count
	)
	SELECT
			@sessionId,
			@DetailTypeSubscription,
			@DetailResultInformation,
			e.dt_detail,
			e.nm_text,
			@retrycount
	FROM    @errTbl e