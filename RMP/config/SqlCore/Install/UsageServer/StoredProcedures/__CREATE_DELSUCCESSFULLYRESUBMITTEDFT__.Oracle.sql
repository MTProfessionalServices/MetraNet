
CREATE OR REPLACE
procedure DelSuccessfullyResubmittedFT (
  p_delay_time int,
  p_mt_now DATE,
  p_DeletedCount out int
  ) as
	begin
			delete from t_failed_transaction
			WHERE dt_FailureTime is NOT NULL and
			State = 'R' and
			p_mt_now > (dt_StateLastModifiedTime + p_delay_time) ;
			
			p_DeletedCount := SQL%ROWCOUNT;
			
	end	;
	