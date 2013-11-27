
      /*
      	CreateUniqueKeyTable
      
      	Creates a single unique constraint table for a partitioned 
      	product view and loads it if it's new.  Also returns the
      	trigger query used to keep this table synchronnized with it's
      	parent product view.
      
      	@ukname - name of a unique constraint
      */
      create proc CreateUniqueKeyTable (
      	@ukname varchar(200),
      	@ins varchar(1000) = '' output,  -- sql for insert stmt
      	@isnew char(1) = 'N' output  -- Y if the uk needs loading
      	) as
      begin
      
      -- Env set up
      set nocount on
      declare @err int	-- sql errors
      declare @rc int	-- row counts
      declare @ret int	-- called proc return codes
      
      -- Table ddl stubs
      declare @ddl varchar(4000)  -- create table
      declare @pk varchar(500)  -- unique key clause
      declare @uk varchar(500)  -- unique key clause
      declare @dbname varchar(500)  -- current db
      set @dbname = db_name()
      set @ddl = 'create table ' + lower(@ukname) + ' (' + char(13)
      set @pk = '   constraint ' + @ukname + '_pk primary key clustered (' + char(13)
      set @uk = '   constraint ' + @ukname + '_uk unique nonclustered (' + char(13)
      set @ins = 'insert into ' + @dbname + '..' + @ukname + ' select'
      set @isnew = 'N'  -- normally, the uk isn't created
      
      -- Select unique cons columns and their types
      declare ukcols cursor for
      	select ucc.position*100, 'uk', nm_column_name,
      		case
      			--
      			-- strings and binary strings
      			when data_type in ('nvarchar', 'varchar', 'nchar', 'char', 
      									'binary', 'varbinary') 
      				then data_type + '(' + cast(character_maximum_length as varchar) + ')'
      			--
      			-- numerics
      			when data_type in ('numeric', 'decimal') 
      				then data_type + '(' + cast(numeric_precision as varchar) + ','
      											+ cast(numeric_scale as varchar) + ')'
      			--
      			-- approximate numerics (maybe float should default to max precision?)
      			when data_type in ('float')
      				then data_type + '(' + cast(numeric_precision as varchar) + ')'
      			--
      			-- undecorated types
      			when data_type in ('bigint', 'int', 'smallint', 'tinyint', 'bit', 'real',
      									'money', 'smallmoney', 'datetime', 'smalldatetime',
      									'sql_variant', 'timestamp', 'uniqueidentifier')
      				then data_type
      			--
      			-- unknown or unsupported types
      			else 'Unsupported('+ data_type + ')'
      		end as type_ddl,
      		case lower(is_nullable)
      			when 'yes' then 'null' else 'not null'
      		end as is_nullable
      	from t_unique_cons uc
      	join t_unique_cons_columns ucc
      		on uc.id_unique_cons = ucc.id_unique_cons
      	join t_prod_view_prop pvp
      		on ucc.id_prod_view_prop = pvp.id_prod_view_prop
      	join t_prod_view pv
      		on pv.id_prod_view = pvp.id_prod_view
      	join information_schema.columns isc
      		on isc.column_name = pvp.nm_column_name 
      		and isc.table_name = pv.nm_table_name
      	where uc.nm_table_name = @ukname
      	--order by ucc.position asc
      	union select  0, 'pk', 'id_sess', 'bigint', 'not null'
      	union select  1, 'pk', 'id_usage_interval', 'int', 'not null'
      	order by 1
      
      -- Iterate each column and build the table ddl
      declare @pos int
      declare @keytype varchar(10)
      declare @col varchar(300)
      declare @type varchar(300)
      declare @nulls varchar(10) -- to null or not to null
      declare @cnt int
      set @cnt = 0
      open ukcols
      
      while (1=1)
      begin
      	fetch ukcols into @pos, @keytype, @col, @type, @nulls
      	if (@@fetch_status <> 0)
      		break
      	set @cnt = @cnt + 1
      	--print str(@cnt) + ' ' + str(@pos) + ' ' + @col + ' ' + @type + ' ' + @nulls
      
      	set @ddl = @ddl + '   ' + @col + ' ' + @type + ' ' + @nulls + ',' + char(13)
      	if (@keytype = 'pk') begin
      		set @pk = @pk + '      ' + @col + ', ' + char(13)
      	end 
      	else begin
      		set @uk = @uk + '      ' + @col + ', ' + char(13)
      	end
      	set @ins = @ins + ' ' + @col + ', '
      
      end 
      deallocate ukcols
      
      -- Check that the unique constraint is defined
      if (@cnt < 1) begin
      	raiserror('Constraint [%s] not defined.', 0, 1, @ukname)
      	return 1
      end
      
      -- Chop trailing comma and finish the insert statement
      set @ins = left(@ins, len(@ins) - 1) + ' from inserted'
      
      -- Chop trailing comma and close the key clauses
      set @pk = left(@pk, len(@pk) - 3) + char(13) + '   )'
      set @uk = left(@uk, len(@uk) - 3) + char(13) + '   )'
      
      -- Compose and close the table ddl
      set @ddl = @ddl + @pk + ',' + char(13) + @uk + char(13) + ')' + char(13)
      --print @ddl
      
      -- If table's already created, skip and return trigger sql
      if object_id(@ukname) is not null
      begin
      	raiserror('Unique key table [%s] already exists.', 0, 1, @ukname)
      	return 0
      end
      
      -- Create the table
      exec (@ddl)
      select @err = @@error, @rc = @@rowcount
      if (@err <> 0) begin
      	raiserror('Cannot create unique key table [%s]', 16, 1, @ukname)
      	return 1
      end
      
      raiserror('Constraint table [%s] created.', 0, 1, @ukname)
      set @isnew = 'Y'
      
      end --proc
 	