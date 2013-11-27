
CREATE procedure DelSuccessfullyResubmittedFT (
  @delay_time int,
  @mt_now DATETIME,
  @DeletedCount int OUTPUT
  ) as
	begin
			delete from t_failed_transaction
			WHERE dt_FailureTime is NOT NULL and
			State = 'R' and
			@mt_now > DATEADD(day, @delay_time, dt_StateLastModifiedTime) ;
			
			set @DeletedCount = @@ROWCOUNT;
			
	end;
 