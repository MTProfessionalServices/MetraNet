CREATE PROCEDURE arch_update_archive_partition_table
(
	@partition_name NVARCHAR(30),
	@partition NVARCHAR(30),
	@interval_id INT,
	@status_to_insert CHAR(1),
	@result nvarchar(4000) OUTPUT
)
AS
BEGIN
	IF( 
		(
			(@partition_name IS NOT NULL) OR EXISTS
						   (
							   SELECT 1 FROM t_partition_interval_map map 
									WHERE id_partition = (SELECT id_partition FROM t_partition_interval_map 
																	WHERE id_interval = @interval_id)
							   AND NOT EXISTS (SELECT 1 FROM t_usage_interval inte 
							                      WHERE inte.id_interval = map.id_interval
															 AND tx_interval_status <> 'H') 
							   AND NOT EXISTS (SELECT 1 FROM t_archive inte 
													WHERE inte.id_interval = map.id_interval
														AND tt_end = dbo.mtmaxdate() and status <> 'E')                         
						   )
		 ) AND (SELECT b_partitioning_enabled FROM t_usage_server) = 'Y'
	  )
    BEGIN
			   UPDATE t_archive_partition
			   SET tt_end = dateadd(s,-1, getdate())
			   WHERE partition_name = ISNULL(@partition_name, @partition)
						AND tt_end = dbo.mtmaxdate()
							AND [status] = @status_to_insert
			   
		
			   IF (@@error <> 0)
			   BEGIN
				  SET @result = '1000016-archive operation failed-->Error in update t_archive_partition table'
				  RETURN
			   END
			   
			   
			   INSERT INTO t_archive_partition VALUES(ISNULL(@partition_name, @partition),@status_to_insert,getdate(),dbo.mtmaxdate())

			   IF (@@error <> 0)
			   BEGIN
				  SET @result = '1000017-archive operation failed-->Error in insert into t_archive_partition table'
				  RETURN
			   END
		   END
END