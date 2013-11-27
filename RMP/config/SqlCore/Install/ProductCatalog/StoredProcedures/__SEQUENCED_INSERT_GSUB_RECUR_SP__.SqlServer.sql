
		create procedure SequencedInsertGsubRecur 
			@p_id_group_sub int,
			@p_id_prop int,
			@p_id_acc int,
			@p_vt_start datetime,
			@p_vt_end datetime,
			@p_tt_current datetime,
			@p_tt_max datetime,
			@p_status int OUTPUT
		as
		begin
		  DECLARE @cnt INTEGER
      SET @p_status = 0
			-- I admit this is a bit wierd, but what I am doing is detecting
			-- a referential integrity failure without generating an error.
			-- This is needed because SQL Server won't let one suppress the
			-- RI failure (and this causes an exception up in ADO land).
			-- This is a little more concise (and perhaps more performant)
			-- than multiple queries up front.
		  INSERT INTO t_gsub_recur_map(id_group, id_prop, id_acc, vt_start, vt_end, tt_start, tt_end) 
			SELECT s.id_group, r.id_prop, a.id_acc, @p_vt_start, @p_vt_end, @p_tt_current, @p_tt_max
      FROM t_sub s
      CROSS JOIN t_account a
      CROSS JOIN t_recur r
      WHERE 
      s.id_group=@p_id_group_sub
      AND
			a.id_acc=@p_id_acc
      AND
      r.id_prop=@p_id_prop

			IF @@rowcount <> 1 
      BEGIN
			-- No row, look for specific RI failure to give better message
		  SELECT @cnt = COUNT(*) FROM t_recur where id_prop = @p_id_prop
			IF @cnt = 0 
        BEGIN
          -- MTPC_CHARGE_ACCOUNT_ONLY_ON_RC
				  SET @p_status = -490799065
				  RETURN
        END
		  SELECT @cnt = COUNT(*) FROM t_account where id_acc = @p_id_acc
			IF @cnt = 0 
        BEGIN
          -- KIOSK_ERR_ACCOUNT_NOT_FOUND
				  SET @p_status = -515899365
				  RETURN
        END
		  SELECT @cnt = COUNT(*) FROM t_sub where id_group = @p_id_group_sub
			IF @cnt = 0 
        BEGIN
          -- Return E_FAIL absent better info
				  SET @p_status = -2147483607
				  RETURN
        END
			-- Return E_FAIL absent better info
      SET @p_status = -2147483607
      END

      -- post-operation business rule check (relies on rollback of work done up until this point)
      -- checks to make sure the receiver's payer's do not violate EBCR cycle constraints
      SELECT @p_status = dbo.CheckGroupReceiverEBCRConstraint(@p_tt_current, @p_id_group_sub)
      IF (@p_status = 1) -- careful... success values between the function and the sproc differ
        SET @p_status = 0

		END
		