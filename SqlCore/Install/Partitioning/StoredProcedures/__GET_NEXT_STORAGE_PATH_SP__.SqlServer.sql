
      /*
      	GetNextStoragePath
      	
      	Returns the next storage path for a partitioned database.
      
      	@path char(500)  -- output is a fully qualified filesystem pathname
      
      */
      create proc GetNextStoragePath
      	@path varchar(500) output  -- fully qualified filesystem pathname
      AS
      begin
      
      set nocount on
      
      -- Error reporting and row counts
      declare @err int
      declare @rc int
      
      -- get count of paths
      declare @pathcnt int
      select @pathcnt = count(*) from t_partition_storage
      if (@pathcnt < 1) begin
      	raiserror('There are no storage paths defined.', 16, 1)
      	return
      end
      
      -- start a transacton
      begin tran
      
      	-- get next path
      	declare @ord int
      	select @path = path, @ord = id_path
      	from t_partition_storage
      	where lower(b_next) = 'y'
      	
      	-- if next flag isn't found or too many found, use first
      	if (@path is null) begin
      		select @path = path, @ord = id_path
      		from t_partition_storage
      		where id_path = 1
      	end
      	
      	-- calculate the new next-path
      	declare @nextord int
      	set @nextord = (@ord%@pathcnt)+1
      
      	-- advance the b_next flag
      	update t_partition_storage set b_next = 'N'
      	update t_partition_storage set b_next = 'Y' where id_path = @nextord
      
      commit
      
      end
      
 	