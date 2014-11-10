
					create or replace procedure UpdateGroupSubMembership(
					p_id_acc int,
					p_id_sub int,
					p_id_po int,
					p_id_group int,	
					p_startdate date,
					p_enddate date,
					p_systemdate date,
					p_status OUT int,
					p_datemodified OUT varchar2,
          p_allow_acc_po_curr_mismatch INTEGER default 0,
          p_allow_multiple_pi_sub_rcnrc INTEGER default 0
					)
					as
					realstartdate date;
					realenddate date;
					begin

						AdjustGsubMemberDates(p_id_sub,p_startdate,p_enddate,
						realstartdate,realenddate,p_datemodified,p_status);
						if p_status <> 1 then
							return;
						end if;

					  /* check that the new date does not conflict with another subscription
						 to the same product offering*/
					  p_status := dbo.checksubscriptionconflicts(p_id_acc,p_id_po,realstartdate,realenddate,p_id_sub,p_allow_acc_po_curr_mismatch,p_allow_multiple_pi_sub_rcnrc) ;
					  if p_status <> 1 then
						return;
					  end if;

					  /* end business rule checks*/
					  begin
						 CreateGSubMemberRecord(p_id_group,p_id_acc,realstartdate,realenddate,
					     p_systemdate,p_status);
                      end;
					end;
				