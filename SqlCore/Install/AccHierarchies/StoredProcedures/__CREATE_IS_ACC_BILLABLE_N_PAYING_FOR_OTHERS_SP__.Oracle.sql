
					create or replace procedure IsAccBillableNPayingForOthers(
						p_id_acc IN integer,
						p_ref_date IN DATE,
						status out integer) 
					as
					begin
				 		/* step 1: Check if this account is billable first
						 MT_ACCOUNT_IS_NOT_BILLABLE ((DWORD)0xE2FF0005L)*/
				 		if dbo.IsAccountBillable(p_id_acc) = 'N' then
							status := -486604795;
							return;
				 		end if;
				 		/* step 2: Now that this account is billable, check if this 
				 		 account has any non paying subscribers (payees) for that
				 		 date passed in
						 MT_ACCOUNT_PAYING_FOR_OTHERS ((DWORD)0xE2FF0030L)*/
				 		if dbo.IsAccountPayingForOthers(p_id_acc, p_ref_date) = 'Y' then
							status := -486604752;
							return;
				 		end if;
				 		/* success*/
						status := 1;
						return;
					end;
				