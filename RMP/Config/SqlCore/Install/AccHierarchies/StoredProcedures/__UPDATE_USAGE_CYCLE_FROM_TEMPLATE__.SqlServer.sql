
CREATE PROCEDURE  UpdateUsageCycleFromTemplate (
	@IdAcc INTEGER
	,@UsageCycleId INTEGER
	,@OldUsageCycle INTEGER
	,@systemDate DATETIME
	,@errorStr NVARCHAR(4000) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @p_status INTEGER
		DECLARE @intervalenddate DATETIME
		DECLARE @intervalID int
		DECLARE @pc_start datetime
		DECLARE @pc_end datetime

		IF @errorStr IS NULL BEGIN
			SET @errorStr = ''
		END

	IF @OldUsageCycle <> @UsageCycleId AND @UsageCycleId <> -1
	BEGIN
		SET @p_status = dbo.IsBillingCycleUpdateProhibitedByGroupEBCR(@systemDate, @IdAcc)
		IF @p_status = 1
		BEGIN
			SET @p_status = 0
			UPDATE t_acc_usage_cycle SET id_usage_cycle = @UsageCycleId
				WHERE id_acc = @IdAcc

				-- post-operation business rule check (relies on rollback of work done up until this point)
				-- CR9906: checks to make sure the account's new billing cycle matches all of it's and/or payee's 
				-- group subscription BCR constraints
			SELECT @p_status = ISNULL(MIN(dbo.CheckGroupMembershipCycleConstraint(@systemDate, groups.id_group)), 1)
				FROM (
					-- gets all of the payer's payee's and/or the payee's group subscriptions
					SELECT DISTINCT gsm.id_group id_group
						FROM t_gsubmember gsm
						INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
						WHERE pay.id_payer = @IdAcc OR pay.id_payee = @IdAcc
					) groups

			IF @p_status = 1
			BEGIN
				SET @p_status = 0
				-- deletes any mappings to intervals in the future from the old cycle
				DELETE FROM t_acc_usage_interval
					WHERE t_acc_usage_interval.id_acc = @IdAcc
					AND	id_usage_interval IN (
						SELECT id_interval
							FROM t_usage_interval ui
							INNER JOIN t_acc_usage_interval aui ON t_acc_usage_interval.id_acc = @IdAcc AND	aui.id_usage_interval = ui.id_interval
							WHERE dt_start > @systemDate
					)

				-- only one pending update is allowed at a time
				-- deletes any previous update mappings which have not yet
				-- transitioned (dt_effective is still in the future)
				DELETE FROM t_acc_usage_interval
					WHERE dt_effective IS NOT NULL
						AND	id_acc = @IdAcc
						AND	dt_effective >= @systemDate

				-- gets the current interval's end date
				SELECT @intervalenddate = ui.dt_end
					FROM t_acc_usage_interval aui
					INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval AND @systemDate BETWEEN ui.dt_start AND ui.dt_end
					WHERE aui.id_acc = @IdAcc

				-- future dated accounts may not yet be associated with an interval (CR11047)
				IF @intervalenddate IS NOT NULL
				BEGIN
					-- figures out the new interval ID based on the end date of the current interval  
					SELECT @intervalID = id_interval
							,@pc_start = dt_start
							,@pc_end = dt_end
						FROM t_pc_interval
						WHERE id_cycle = @usagecycleID
							AND	dbo.addsecond(@intervalenddate) BETWEEN dt_start AND dt_end

					-- inserts the new usage interval if it doesn't already exist
					-- (needed for foreign key relationship in t_acc_usage_interval)
					INSERT INTO t_usage_interval
						SELECT @intervalID
								,@UsageCycleId
								,@pc_start
								,@pc_end
								,'O'
							WHERE @intervalID NOT IN (SELECT id_interval FROM t_usage_interval)

					-- creates the special t_acc_usage_interval mapping to the interval of
					-- new cycle. dt_effective is set to the end of the old interval.
					INSERT INTO t_acc_usage_interval
						SELECT @IdAcc
								,@intervalID
								,ISNULL(tx_interval_status, 'O')
								,@intervalenddate
							FROM t_usage_interval
							WHERE id_interval = @intervalID
								AND tx_interval_status != 'B'
				END
			END
		END
		ELSE
		BEGIN 
			SET @errorStr = 'Billing cycle is not updated for account ' + @IdAcc + '. Billing cycle update is prohibited by group EBCR.'
		END
	END
END
