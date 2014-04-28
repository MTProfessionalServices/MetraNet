
create procedure CreateAdjustmentTable(@p_id_pi_type INTEGER,  @p_status INTEGER OUTPUT, @p_err_msg VARCHAR(512) OUTPUT)
as
  declare @CursorVar CURSOR
  declare @columncursor CURSOR
  declare @count integer
  declare @i integer
  declare @pvname nvarchar(256)
  declare @adjname nvarchar(256)
  declare @ddlstr as varchar(max)
  declare @idpi as int
  declare @innercount as int
  declare @j as int
  declare @columnname as nvarchar(256)
  declare @datatype as nvarchar(256)
  declare @pv nvarchar(255)
  declare @newpiname nvarchar(255)
  declare @piname nvarchar(255)
  declare @old_pi as int
  declare @new_pi as int
  declare @pvTable as nvarchar(256)
  declare @ajColumnName as nvarchar(256)
  declare @columnDescription as nvarchar(max)
  declare @cursorColumnDescription CURSOR
  declare @countColumnDescriptions as int  
  declare @indexColumnDescriptions as int

  set @p_status = 0
  select TOP 1 @pv = pi1.nm_productview, @piname = bp.nm_name, @newpiname = bpnew.nm_name,
               @old_pi = pi2.id_pi, @new_pi = pi1.id_pi
  from t_pi pi1
  inner join t_pi pi2 on pi1.nm_productview = pi2.nm_productview
  inner join t_base_props bp on bp.id_prop = pi2.id_pi
  inner join t_base_props bpnew on bpnew.id_prop = pi1.id_pi
  where pi1.id_pi = @p_id_pi_type AND pi2.id_pi <> pi1.id_pi
  if LEN(@pv) > 0
  BEGIN
  
      select @p_status = count(*)
      from (

          -- Fast way to compare two tables, from
          -- http://weblogs.sqlteam.com/jeffs/archive/2004/11/10/2737.aspx
          -- Look for rows that are in one table, but not the other.
          select min(TableName) as TableName, colname, coltype
          from
          (

              select 'Table A' as TableName, a.colname, a.coltype
              from
              (
                  -- Select name and type of PV properties for charges associated with @new_pi 
                  select prop.nm_column_name as colname, 
                         prop.nm_data_type as coltype
                  from t_charge join t_prod_view_prop prop 
                  on prop.id_prod_view_prop = t_charge.id_amt_prop
                  where id_pi = @new_pi
              ) a

              UNION ALL

              select 'Table B' as TableName, b.colname, b.coltype
              from
              (
                  -- Select name and type of PV properties for charges associated with @old_pi 
                  select prop.nm_column_name as colname, 
                         prop.nm_data_type as coltype
                  from t_charge join t_prod_view_prop prop 
                  on prop.id_prod_view_prop = t_charge.id_amt_prop
                  where id_pi = @old_pi
              ) b
      
          ) y
          group by colname, coltype
          having count(*) = 1

      ) z;

      if @p_status <> 0 
      begin 
        SELECT @p_err_msg = 'Product View ''' + @pv + ''' is shared between ''' +  @newpiname + ''' and ''' + @piname + '''';
        SELECT @p_err_msg = @p_err_msg + '. If ''' + @newpiname + ''' is adjustable, make sure that charges in these priceable item types are the same.'; 
      end
  END

	CREATE TABLE #ColumnDescriptionTbl
	(
		ColumnDescriptionStatement nvarchar(max)
	)

	SET @CursorVar = CURSOR FORWARD_ONLY STATIC
	FOR
	select distinct(pv.nm_table_name),
	't_aj_' + substring(pv.nm_table_name,6,1000),
	t_pi.id_pi
	from 
	t_pi
	-- all of the product views references by priceable items
	INNER JOIN t_prod_view pv on upper(pv.nm_name) = upper(t_pi.nm_productview)
	-- BP changed next join to 'left outer' from 'inner'
	-- in order to support Amount adjustments for PIs that don't
	-- have any charges
	LEFT OUTER JOIN t_charge on t_charge.id_pi = t_pi.id_pi
  WHERE t_pi.id_pi = @p_id_pi_type
	select @i = 0
	OPEN @CursorVar
	Set @count = @@cursor_rows
	while(@i < @count) begin
		select @i = @i + 1
		FETCH NEXT FROM @CursorVar into @pvname,@adjname,@idpi
	-- create the table
		set @columncursor = CURSOR FORWARD_ONLY STATIC
		for
		select prop.nm_column_name,prop.nm_data_type from t_charge 
			INNER JOIN t_prod_view_prop prop on prop.id_prod_view_prop = t_charge.id_amt_prop
			where id_pi = @idpi
		OPEN @columncursor
		set @innercount = @@cursor_rows
		select @j = 0
    set @columnDescription = ''
    select @ddlstr =  ('if NOT exists (select * from dbo.sysobjects where id = object_id(''' + @adjname + ''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) ')
    select @ddlstr = @ddlstr + 'create table ' + @adjname + ' (id_adjustment int'
		while (@j < @innercount) begin
			FETCH NEXT FROM @columncursor into @columnname,@datatype
			set @ajColumnName = 'c_aj_' + right(@columnname,len(@columnname)-2)
			select @ddlstr = (@ddlstr + ', ' + @ajColumnName + ' ' + @datatype)
			select @columnDescription = 'DECLARE @columnDesc nvarchar(256) '
			-- gets column description from t_pv_* table			
			+ 'SELECT @columnDesc = CONVERT(nvarchar(256), value) '
			+ 'FROM fn_listextendedproperty (''MS_Description'', ''SCHEMA'', ''dbo'', ''table'', '''+@pvname+''', ''column'', '''+@columnname+''') '
			-- creates column description 
			+ ' IF EXISTS (SELECT 1 FROM fn_listextendedproperty(N''MS_Description'', N''SCHEMA'', N''dbo'', N''TABLE'', ''' + @adjname + ''', ''column'', ''' + @ajColumnName + ''')) '
			  + 'BEGIN EXEC sp_dropextendedproperty @name = N''MS_Description'', @level0type = N''SCHEMA'', @level0name = N''dbo'','
						+ '@level1type = N''TABLE'', @level1name = '''+ @adjname+''','
						+ '@level2type=N''COLUMN'',@level2name='''+  @ajColumnName +''' '
			  +	'END '
					+ 'EXEC sys.sp_addextendedproperty '
					+ '@name=N''MS_Description'', @value=@columnDesc,'
					+ '@level0type=N''SCHEMA'',@level0name=N''dbo'','
					+ '@level1type=N''TABLE'',@level1name='''+@adjname+''','
					+ '@level2type=N''COLUMN'',@level2name='''+  @ajColumnName +''' '
			insert into #ColumnDescriptionTbl(ColumnDescriptionStatement) values (@columnDescription)
			
			select @j = @j+1
		end
		select @ddlstr = (@ddlstr + ')')
		exec (@ddlstr)
		-- creates table description
		exec (
		' IF EXISTS (SELECT 1 FROM fn_listextendedproperty(N''MS_Description'', N''SCHEMA'', N''dbo'', N''TABLE'', ''' + @adjname + ''', default, default)) '
		  + 'BEGIN EXEC sp_dropextendedproperty @name = N''MS_Description'', @level0type = N''SCHEMA'', @level0name = N''dbo'','
					+ '@level1type = N''TABLE'', @level1name = '''+ @adjname +''''
		  +	'END '
		  + 'EXEC sys.sp_addextendedproperty'
					+ ' @name=N''MS_Description'', @value=''Autogenerated adjustment table. Contains adjustments for charges in product view table "' + @pvname + '"'','
					+ ' @level0type=N''SCHEMA'',@level0name=N''dbo'','
					+ ' @level1type=N''TABLE'',@level1name='''+ @adjname + '''')
		-- creates columns descriptions
		--exec ('DECLARE @columnDesc varchar(100) ' + @columdDescription)
		set @cursorColumnDescription = CURSOR FORWARD_ONLY STATIC
		for
		select ColumnDescriptionStatement from #ColumnDescriptionTbl			
		OPEN @cursorColumnDescription
		set @countColumnDescriptions = @@cursor_rows
		set @indexColumnDescriptions = 0
		while (@indexColumnDescriptions < @countColumnDescriptions) begin
			FETCH NEXT FROM @cursorColumnDescription into @columnDescription
			exec (@columnDescription)
			set @indexColumnDescriptions = @indexColumnDescriptions+1
		end		
		CLOSE @CursorColumnDescription
		DEALLOCATE @CursorColumnDescription
		
		CLOSE @columncursor
		DEALLOCATE @columncursor
	end
	CLOSE @CursorVar
	DEALLOCATE @CursorVar