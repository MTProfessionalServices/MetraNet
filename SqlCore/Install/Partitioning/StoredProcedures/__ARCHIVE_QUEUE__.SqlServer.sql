CREATE PROCEDURE archive_queue(
    @update_stats    CHAR(1) = 'N',
    @sampling_ratio  VARCHAR(3) = '30',
    @current_time    DATETIME = NULL,
    @result          NVARCHAR(4000) OUTPUT
)
AS
	/*
	How to run this stored procedure:	
	DECLARE @result NVARCHAR(2000)
	EXEC archive_queue @result = @result OUTPUT
	PRINT @result
	
	Or if we want to update statistics and change current date/time also:	
	DECLARE @result            NVARCHAR(2000),
	        @current_time  DATETIME
	SET @current_time = GETDATE()
	EXEC archive_queue 'Y',
	     30,
	     @current_time = @current_time,
	     @result = @result OUTPUT
	PRINT @result	
	*/
	
SET NOCOUNT ON;
DECLARE @TRYAGAIN INT = 1;
DECLARE @GainedAccess BIT = 1;
DECLARE @AccessTable table (
	[archival_in_progress] [bit] NULL,
	[reconciliation_in_progress] [bit] NULL) ;

WHILE ( @TRYAGAIN = 1)
begin
  update [t_execution_monitoring] 
       SET archival_in_progress = 1
	  OUTPUT INSERTED.archival_in_progress, INSERTED.reconciliation_in_progress into @AccessTable
	  WHERE reconciliation_in_progress = 0;

select top 1 @GainedAccess=reconciliation_in_progress from @AccessTable;

 if (@GainedAccess = 1)
    begin
      /* Update didn't succeed goto sleep and try again */
      WAITFOR DELAY '00:00:02';
      CONTINUE;
    END    
  ELSE
    BEGIN TRY
  	  IF dbo.IsSystemPartitioned() = 1
          EXEC archive_queue_partition
	         @update_stats = @update_stats,
	         @sampling_ratio = @sampling_ratio,
	         @current_time = @current_time,
	         @result = @result OUTPUT
        ELSE
          EXEC archive_queue_nonpartition
	         @update_stats = @update_stats,
	         @sampling_ratio = @sampling_ratio,
	         @result = @result OUTPUT
        
    END TRY
    Begin Catch
        SELECT
             ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
    End Catch
  SET  @TRYAGAIN = 0
END --while
  update t_execution_monitoring  set archival_in_progress = 0
