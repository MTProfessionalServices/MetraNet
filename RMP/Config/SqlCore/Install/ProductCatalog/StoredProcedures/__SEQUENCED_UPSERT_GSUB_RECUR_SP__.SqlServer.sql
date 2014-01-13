
		create procedure SequencedUpsertGsubRecur 
			@p_id_group_sub int,
			@p_id_prop int,
			@p_id_acc int,
			@p_vt_start datetime,
			@p_vt_end datetime,
			@p_tt_current datetime,
			@p_tt_max datetime,
			@p_allow_acc_po_curr_mismatch int = 0,
			@p_status int OUTPUT
		as
		begin
	  	  set @p_status = 0
	  	  DECLARE @p_id_po INTEGER

		  select @p_id_po = id_po 
			from t_sub sub
			inner join t_group_sub gsub
			on sub.id_group = gsub.id_group
			where gsub.id_group = @p_id_group_sub

   		       -- Check that both account and PO have the same currency only when @p_allow_acc_po_curr_mismatch flag is 0
              if (isnull(@p_allow_acc_po_curr_mismatch,0) = 0)
		      BEGIN
					if (dbo.IsAccountAndPOSameCurrency(@p_id_acc, @p_id_po) = '0')
					begin
					-- MT_ACCOUNT_PO_CURRENCY_MISMATCH
					select @p_status = -486604729
					return
					end
			  END		  
		  
		  exec SequencedDeleteGsubRecur @p_id_group_sub, @p_id_prop, @p_vt_start, @p_vt_end, @p_tt_current, @p_tt_max, @p_status output
      if @p_status <> 0 return
		  exec SequencedInsertGsubRecur @p_id_group_sub, @p_id_prop, @p_id_acc, @p_vt_start, @p_vt_end, @p_tt_current, @p_tt_max, @p_status output
		end
		