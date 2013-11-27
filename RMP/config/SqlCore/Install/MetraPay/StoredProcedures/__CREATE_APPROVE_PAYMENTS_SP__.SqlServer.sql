
      CREATE PROCEDURE ApprovePayments
			@id_interval int,
			@id_acc int,
			@status int output
			AS
			BEGIN
			  SET @status = -1

				-- It is not necessary to use the temp table here.
				-- However, since there is currently no index on the 
				-- t_acc_uage.id_usage_interval column, to improve the 
				-- performance, the temp table is used so that the 
				-- id_sess be looked up only once for the two deletions.
				DECLARE @id_enum int
				SELECT
				  @id_enum = id_enum_data
				FROM
				  t_enum_data
				WHERE
				  nm_enum_data = 'metratech.com/paymentserver/PaymentStatus/Pending'
				IF ((@@ERROR != 0) OR (@@ROWCOUNT = 0)) 
				BEGIN
					GOTO FatalError
				END

				UPDATE t_pv_ps_paymentscheduler
				SET 
				  c_currentstatus = @id_enum
				where
					c_originalaccountid = @id_acc And c_originalintervalid = @id_interval
  
				IF (@@ERROR != 0)
				BEGIN
					GOTO FatalError
				END

				SET @status = 0
				RETURN 0

			FatalError:
			SET @status = -1

			END
      