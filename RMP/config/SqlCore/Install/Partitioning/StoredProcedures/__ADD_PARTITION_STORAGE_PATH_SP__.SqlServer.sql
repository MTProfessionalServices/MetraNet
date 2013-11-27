
      /*
      	AddPartitionStoragePath
      	
      	Adds a path (1 row) to the t_partition_storage table
      
      	@path char(500)  -- fully qualified filesystem pathname
      
      */
      create proc AddPartitionStoragePath
      	@path char(500)  -- fully qualified filesystem pathname
      AS
      begin
      
      set nocount on
      
      -- Error reporting and row counts
      declare @err int
      declare @rc int
      
      -- get next path id
      declare @nextid int
      select @nextid = coalesce(max(id_path), 0) + 1
      from t_partition_storage
      
      insert into t_partition_storage (id_path, b_next, path)
      values (@nextid, 'N', @path)
      
      end
      
 	