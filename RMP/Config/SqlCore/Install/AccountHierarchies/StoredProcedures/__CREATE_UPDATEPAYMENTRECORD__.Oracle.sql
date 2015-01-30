
					CREATE OR REPLACE procedure updatepaymentrecord(
					 p_payer IN int,
					 p_payee IN int,
					 p_oldstartdate IN date,
					 p_oldenddate IN date,
					 p_startdate IN date,
					 p_enddate IN date,
					 p_systemdate IN date,
					 p_enforce_same_corporation varchar2,
					 p_account_currency nvarchar2,
					 p_status OUT int
					)
					as
					 realoldstartdate date;
					 realoldenddate date;
					 realstartdate date;
					 realenddate date;
					 testenddate date;
					 billable char;
					 varMaxDateTime DATE;
					 tempvar integer;
					 accstartdate date;
					begin
					 varMaxDateTime := dbo.MTMaxDate();
					 p_status := 0;
					 /* normalize dates*/
					 realstartdate := dbo.mtstartofday(p_startdate);
					 if p_enddate is null then
					  realenddate := dbo.mtstartofday(varMaxDateTime); 
					 else
					  realenddate := dbo.mtstartofday(p_enddate) ;
					 end if;
					 realoldstartdate := dbo.mtstartofday(p_oldstartdate);
					 realoldenddate   := dbo.mtstartofday(p_oldenddate) ;
					 /* business rule checks
					  if the account is not billable, we must make sure that they are 
					  not changing the most recent payment redirection record's end date from
					  MTMaxDate(). */
					  begin
                          for i in (
						  select max(vt_end) vt_end, c_billable 
						  from t_payment_redirection redir
						  INNER JOIN t_av_internal tav on tav.id_acc = p_payee
						  where
						  redir.id_payee = p_payee and redir.id_payer = p_payer
						  group by c_billable)
                          loop
                            testenddate := i.vt_end;
                            billable    := i.c_billable;
                          end loop;
					  end;
					  /* if the enddate matches the record we are changing*/
					  if testenddate = realoldenddate AND
					  /* the user is changing the enddate and the account is not billable*/
					  realoldenddate <> realenddate AND billable = 'N' then
					   /* MT_PAYMENT_UDDATE_END_DATE_INVALID*/
					   p_status := -486604780;
					   return;
					  end if;
					  if (p_oldenddate = varMaxDateTime AND p_enddate <> varMaxDateTime) then
						 /* MT_CANNOT_MOVE_MODIFY_PAYMENT_ENDDATE_IF_INFINITE*/
						 p_status := -486604749;
						 return;
					  end if;
					  begin
						  select dbo.mtstartofday(dt_crt) into accstartdate from t_account where id_acc = p_payee;
					  exception
						when no_data_found then
						null;
					  end;  
					  if (p_oldstartdate = accstartdate AND p_startdate <> accstartdate) then
						 /* MT_CANNOT_MOVE_MODIFY_PAYMENT_STARTDATE_IF_ACC_STARTDATE*/
						 p_status := -486604748;
						 return;
					  end if;
					 /* end business rules*/
					 CreatePaymentRecord(p_payer,p_payee,realstartdate,realenddate,NULL,p_systemdate,'Y',p_enforce_same_corporation, p_account_currency,p_status);
					 if p_status is null then
						  /* MT_PAYMENTUPDATE_FAILED*/
						  p_status := -486604781;
					  end if;
					end;
				