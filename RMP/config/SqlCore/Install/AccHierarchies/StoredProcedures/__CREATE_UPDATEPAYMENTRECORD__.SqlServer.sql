
create procedure UpdatePaymentRecord(
@p_payer int,
@p_payee int,
@p_oldstartdate datetime,
@p_oldenddate datetime,
@p_startdate datetime,
@p_enddate datetime,
@p_systemdate datetime,
@p_enforce_same_corporation varchar,
@p_account_currency nvarchar(5),
@p_status int OUTPUT
)
as
begin
declare @realoldstartdate datetime
declare @realoldenddate datetime
declare @realstartdate datetime
declare @realenddate datetime
declare @testenddate datetime
declare @billable char
declare @varMaxDateTime datetime
declare @accstartdate datetime
declare @tempvar int
select @varMaxDateTime = dbo.MTMaxDate()
select @p_status = 0
-- normalize dates
select @realstartdate = dbo.mtstartofday(@p_startdate) 
if (@p_enddate is null)
	begin
	select @realenddate = dbo.mtstartofday(@varMaxDateTime)  
	end
else
	begin
	select @realenddate = dbo.mtstartofday(@p_enddate) 
	end
select @realoldstartdate = dbo.mtstartofday(@p_oldstartdate) 
select @realoldenddate = dbo.mtstartofday(@p_oldenddate)  
 -- business rule checks
 -- if the account is not billable, we must make sure that they are 
	-- not changing the most recent payment redirection record's end date from
	-- MTMaxDate(). 
select @testenddate = max(vt_end), @billable = c_billable from t_payment_redirection redir
INNER JOIN t_av_internal tav on tav.id_acc = @p_payee
where
redir.id_payee = @p_payee and redir.id_payer = @p_payer
group by c_billable
 -- if the enddate matches the record we are changing
if (@testenddate = @realoldstartdate AND
-- the user is changing the enddate and the account is not billable
@realoldenddate <> @realenddate AND @billable = '0')
	begin
	-- MT_PAYMENT_UDDATE_END_DATE_INVALID
	select @p_status = -486604780
	return
	end 
if (@p_oldenddate = @varMaxDateTime AND @p_enddate <> @varMaxDateTime) begin
	-- MT_CANNOT_MOVE_MODIFY_PAYMENT_ENDDATE_IF_INFINITE
	select @p_status = -486604749
	return
end
select @accstartdate = dbo.mtstartofday(dt_crt) from t_account where id_acc = @p_payee
if (@p_oldstartdate = @accstartdate AND @p_startdate <> @accstartdate) begin
	-- MT_CANNOT_MOVE_MODIFY_PAYMENT_STARTDATE_IF_ACC_STARTDATE
	select @p_status = -486604748
	return
end
-- end business rules
exec CreatePaymentRecord @p_payer,@p_payee,@realstartdate,@realenddate,NULL,@p_systemdate,'Y', @p_enforce_same_corporation, 
												@p_account_currency, @p_status output
 /*ESR-5307 TELUS: Can't change payer effective start date to a later date */
 IF (@realstartdate > (select vt_start from t_payment_redirection 
	where id_payer = @p_payer and id_payee = @p_payee 
	and vt_end = @realenddate ))
	select @p_status = -486604736
  
if (@p_status is null)
	begin
	-- MT_PAYMENTUPDATE_FAILED
	select @p_status = -486604781
	end
end
		 