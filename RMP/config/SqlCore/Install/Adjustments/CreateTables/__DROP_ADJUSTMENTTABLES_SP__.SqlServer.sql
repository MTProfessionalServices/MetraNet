
      create proc DropAdjustmentTables
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
	      INNER JOIN t_charge on t_charge.id_pi = t_pi.id_pi
	      select @i = 0
	      OPEN @CursorVar
	      Set @count = @@cursor_rows
	      while(@i < @count) begin
		      select @i = @i + 1
		      FETCH NEXT FROM @CursorVar into @pvname,@adjname,@idpi
		      -- drop the table if it exists
		      select @ddlstr =  ('if exists (select * from dbo.sysobjects where id = object_id(''' + @adjname + ''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) drop table ' + @adjname)
		      exec (@ddlstr)
	      end
	      CLOSE @CursorVar
	      DEALLOCATE @CursorVar
		
