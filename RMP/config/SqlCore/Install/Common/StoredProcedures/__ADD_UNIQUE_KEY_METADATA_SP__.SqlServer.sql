
      /*
      	AddUniqueKeyMetadata

      	Adds a unique key definintion to the metadata tables.
      	An alternative to InsertProductViewUniqueKey and
      	InsertProdcutViewUniqueKeyCol.

      	@tabname - name of a product view
      	@consname - name of the unique key
      	@cols - comma sep list of column names

      */
      create proc AddUniqueKeyMetadata(
      	@tabname varchar(200),
      	@consname	varchar(200),
      	@cols varchar(4000)
      	) as
      begin

      declare @err int
      -- Env set up
      set nocount on

      declare @localtran int
      set @localtran = 0
      if (@@trancount = 0) begin
      	begin tran
      	set @localtran = 1
      end

      -- Get product view id
      declare @idpv int
      select @idpv = id_prod_view
      	from t_prod_view
      	where lower(nm_table_name) = lower(@tabname)

      if (@idpv is null) begin
      	raiserror('Product view [%s] does not exist.', 16, 1, @tabname)
      	if (@localtran = 1) rollback
      	return 1
      end

      -- Insert the unique key name
      declare @iduk int
      insert into t_unique_cons (id_prod_view, constraint_name, nm_table_name)
      	values (@idpv, @consname, 't_uk_' + @consname)

      set @err = @@error
      set @iduk = @@identity
      if (@err <> 0) begin
      	raiserror('Can''t add key [%s] to table [%s]', 16, 1,
      		@consname, @tabname)
      	if (@localtran = 1) rollback
      	return 1
      end

      -- Insert the columns
      declare @propid int
      declare @col varchar(200)
      declare @pos int
      set @pos = 0

      -- Process the csv of column names
      -- Remove spaces and tabs; append eos
      set @cols = replace(@cols, char(9), '')
      set @cols = replace(@cols, ' ', '') + ','

      while (len(@cols) > 0) begin

      	-- Pop a column off the csv
      	set @col = left(@cols, charindex(',', @cols)-1)
      	set @cols = right(@cols, len(@cols) - charindex(',', @cols))

      	-- Ignore empty columns
      	if (@col = '')
      		continue

      	set @pos = @pos + 1

      	-- Get property id of column
      	select @propid = id_prod_view_prop
      		from t_prod_view_prop
      		where id_prod_view = @idpv
      		 and lower(nm_column_name) = lower(@col)

      	if (@propid is null) begin
      		if (@localtran = 1) rollback
      		raiserror('Product view [%s] has no column named [%s]', 16, 1,
      			@tabname, @col)
      		return 1
      	end

      	-- Insert new column
      	insert t_unique_cons_columns
      		values (@iduk, @propid, @pos)

      	set @err = @@error
      	if (@err <> 0) begin
      		raiserror('Can''t add column [%s] to key [%s]', 16, 1,
      			@col, @consname)
      		if (@localtran = 1) rollback
      		return 1
      	end

      end	-- csv process loop

      if (@localtran = 1)
      	commit

      end --proc
 	