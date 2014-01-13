
create procedure GenerateAdjustmentTables
as
	DECLARE @CursorVar CURSOR
	declare @columncursor CURSOR
	declare @count integer
	declare @i integer
	declare @pvname varchar(256)
	declare @adjname varchar(256)
	declare @ddlstr as varchar(8000)
	declare @idpi as int
	declare @innercount as int
	declare @j as int
	declare @columnname as varchar(256)
	declare @datatype as varchar(256)
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
	select @i = 0
	OPEN @CursorVar
	Set @count = @@cursor_rows
	while(@i < @count) begin
		select @i = @i + 1
		FETCH NEXT FROM @CursorVar into @pvname,@adjname,@idpi
		-- drop the table if it exists
		select @ddlstr =  ('if exists (select * from dbo.sysobjects where id = object_id(''' + @adjname + ''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) drop table ' + @adjname)
		exec (@ddlstr)
		-- create the table
		set @columncursor = CURSOR FORWARD_ONLY STATIC
		for
		select prop.nm_column_name,prop.nm_data_type from t_charge 
			INNER JOIN t_prod_view_prop prop on prop.id_prod_view_prop = t_charge.id_amt_prop
			where id_pi = @idpi
		OPEN @columncursor
		set @innercount = @@cursor_rows
		select @j = 0,@ddlstr = 'create table ' + @adjname + ' (id_adjustment int'
		while (@j < @innercount) begin
			FETCH NEXT FROM @columncursor into @columnname,@datatype
			select @ddlstr = (@ddlstr + ', c_aj_' + right(@columnname,len(@columnname)-2) + ' ' + @datatype)
			select @j = @j+1
		end
		select @ddlstr = (@ddlstr + ')')
		exec (@ddlstr)
		CLOSE @columncursor
		DEALLOCATE @columncursor
	end
	CLOSE @CursorVar
	DEALLOCATE @CursorVar
		
