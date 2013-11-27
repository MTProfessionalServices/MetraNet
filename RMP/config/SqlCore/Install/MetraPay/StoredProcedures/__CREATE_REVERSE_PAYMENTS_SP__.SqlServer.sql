
			CREATE PROCEDURE ReversePayments
						@id_interval int,
						@id_acc int,
						@id_enum int,
						@status int OUTPUT
			AS
			BEGIN
			  /*************************************************
				** Procedure Name: MTSP_REVERSE_PAYMENT_BILLING
				** 
				** Procedure Description: 
				**
				** Parameters: 
				**
				** Returns: 0 if successful
				**          -1 if fatal error occurred
				**
				** Created By: Ning Zhuang
				** Created On: 12/10/2002
				** Last Modified On: 
				**************************************************/
				SET @status = -1
	
				-- It is not necessary to use the temp table here.
				-- However, since there is currently no index on the 
				-- t_acc_uage.id_usage_interval column, to improve the 
				-- performance, the temp table is used so that the 
				-- id_sess be looked up only once for the two deletions.

				-- Delete only those records that are still in pending approval
				-- status
				SELECT pv.id_sess
				INTO #tmp
				FROM t_pv_ps_paymentscheduler pv
				INNER JOIN t_acc_usage au
				ON au.id_sess = pv.id_sess 
				AND (au.id_acc = @id_acc OR @id_acc = -1)
				AND pv.c_originalintervalid = @id_interval
				AND pv.c_currentstatus = @id_enum
				IF @@ERROR <> 0 GOTO FatalError
					
				DELETE FROM t_acc_usage
				WHERE id_sess IN (SELECT id_sess FROM #tmp)
				IF @@ERROR <> 0 GOTO FatalError
				
				DELETE FROM t_pv_ps_paymentscheduler
				WHERE id_sess IN (SELECT id_sess FROM #tmp)
				IF @@ERROR <> 0 GOTO FatalError
				
				DROP TABLE #tmp
				IF @@ERROR <> 0 GOTO FatalError
				
				SET @status = 0
				RETURN 0
				
				FatalError:
			  	SET @status = -1
					RETURN -1
				END
      	