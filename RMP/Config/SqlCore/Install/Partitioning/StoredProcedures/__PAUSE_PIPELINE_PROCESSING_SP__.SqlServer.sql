
/*
	Proc: PausePipelineProcessing

	Pauses pipeline processing. Waits up to 2 minutes for the pipeline to pause.
*/
create proc [PausePipelineProcessing](@state int) as
BEGIN
	declare @status int
	declare @timeout int
	set @timeout = 0;
	set @status = case @state when 0 then 0 else 1 end; /* ensure only 0 or 1 is a valid status */
	
	update t_pipeline set b_paused = @status;
	
	while ((select COUNT(*) from t_pipeline where b_processing = 1) > 0) and (@status = 1)
	begin
		if @timeout > 12 /* wait up to 2 minutes for pipeline state */
			break;

		waitfor delay '00:00:10';
		set @timeout = @timeout + 1;
	end;
	
	/* silently let the process continue if we exceed 2 minutes to let core processes run */
END
