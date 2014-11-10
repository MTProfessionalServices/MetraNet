
				CREATE PROCEDURE CheckAccountStateDateRules (
				  @p_id_acc integer,
					@p_old_status varchar(2),
					@p_new_status varchar(2),
					@p_ref_date datetime,
					@status integer output)
				AS
				BEGIN
					declare @dt_crt datetime
	
					-- Rule 1: There should be no updates with dates earlier than 
					-- inception date
					SELECT 
					  @dt_crt = dbo.mtstartofday(dt_crt)
					FROM 	
					  t_account 
					WHERE
					  id_acc = @p_id_acc

					IF (dbo.mtstartofday(@p_ref_date) < @dt_crt)
					BEGIN
					  -- MT_SETTING_START_DATE_BEFORE_ACCOUNT_INCEPTION_DATE_NOT_ALLOWED
					  -- (DWORD)0xE2FF002EL
					  SELECT @status = -486604754
					  return
					END

					-- Rule 2: If updating from active to active state and there is usage
					-- and there should be no updates with dates later than the existing date
					IF ((@p_old_status = 'AC') AND 
							(@p_new_status = 'AC') AND
							(dbo.mtstartofday(@p_ref_date) > @dt_crt))
					BEGIN
						IF EXISTS (
						SELECT TOP 1 
							id_acc
						FROM
							t_acc_usage
						WHERE
							id_acc = @p_id_acc)
						BEGIN
							-- ACCOUNT_CONTAINS_USAGE_ACTIVE_DATE_MOVE_IN_FUTURE_NOT_ALLOWED
							-- (DWORD)0xE406000EL
							SELECT @status = -469368818
							return
						END
					END

					-- Rule 3: There should be no updates with dates later than 
					-- inception date for the first interval, creating gaps in account state
					IF (@p_old_status = @p_new_status) 
					BEGIN
					    if EXISTS( 
					    select 1
					    from t_account_state tas
					    where tas.status = @p_new_status
					      and tas.id_acc = @p_id_acc
					      and @p_ref_date > vt_start
					      and @p_ref_date <= vt_end
					      and vt_start = @dt_crt
					    )
					    BEGIN
							-- MT_START_DATE_AFTER_ACCOUNT_INCEPTION_DATE_NOT_ALLOWED
							-- (DWORD)0xE2FF0059L
							SELECT @status = -486604711
							return
					    END
					END

					select @status = 1
				 END
				