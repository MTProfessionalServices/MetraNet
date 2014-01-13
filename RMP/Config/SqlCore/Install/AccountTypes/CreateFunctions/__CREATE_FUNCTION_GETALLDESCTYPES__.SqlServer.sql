
        Create Function dbo.GetAllDescendentAccountTypes
        (
          @parent varchar(200)
        )
        RETURNS @retDescendents TABLE (DescendentTypeName varchar(200))
        AS
        Begin
          declare @parentid int
          select @parentid = id_type from t_account_type where name = @parent

          DECLARE @directdesc TABLE (id_desc int not null)

          --create table #directdesc (id_desc int not null)
          insert into @directdesc
          select id_descendent_type from t_acctype_descendenttype_map amap
            where amap.id_type = @parentid


          declare @numrows integer
          set @numrows = 1 -- to get started
          while (@numrows <> 0)
          begin
            insert into @directdesc
     	        select id_descendent_type from t_acctype_descendenttype_map amap
     	        inner join @directdesc tempt on tempt.id_desc = amap.id_type
       		        where id_descendent_type not in (select id_desc from @directdesc)
            set @numrows = @@ROWCOUNT
          end

          insert @retDescendents
            SELECT t_account_type.name from @directdesc tempt
            inner join t_account_type on tempt.id_desc = t_account_type.id_type 
            RETURN
        	
        End
			