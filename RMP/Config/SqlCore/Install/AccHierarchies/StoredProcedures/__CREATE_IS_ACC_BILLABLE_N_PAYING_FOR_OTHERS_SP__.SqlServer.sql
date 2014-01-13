
					create procedure IsAccBillableNPayingForOthers(
						@id_acc int,
						@ref_date datetime,
						@status int output) 
					as
					begin
				 		-- step 1: Check if this account is billable first
						-- MT_ACCOUNT_IS_NOT_BILLABLE ((DWORD)0xE2FF0005L)
				 		if (dbo.IsAccountBillable(@id_acc) = 'N')
						  begin
							select @status = -486604795
							return
				 		  end 
				 		-- step 2: Now that this account is billable, check if this 
				 		-- account has any non paying subscribers (payees)
						-- MT_ACCOUNT_PAYING_FOR_OTHERS ((DWORD)0xE2FF0030L)
				 		if (dbo.IsAccountPayingForOthers(@id_acc,@ref_date) = 'Y')
						  begin
							select @status = -486604752
							return
				 		  end 
				 		-- success
						
						select @status = 1
						return
					end
				