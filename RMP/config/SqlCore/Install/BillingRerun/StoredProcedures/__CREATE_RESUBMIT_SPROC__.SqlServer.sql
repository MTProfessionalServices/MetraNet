
Create Procedure resubmit @rerun_table_name nvarchar(30), @message_size int, @metradate nvarchar(30), 
@context text, @return_code int OUTPUT 
      as
      begin
      declare @sql nvarchar (4000)
      declare @args NVARCHAR(255)
      declare @id_svc int
      declare @curr_sessions int
      declare @maxsize int
      declare @num_parent_sessions int
      declare @num_service_sessions int
      set @maxsize = @message_size
      declare @runningTotal int
      declare @id_ss_start int
      declare @id_schedule_start int
      declare @child_svc int
      declare @id_parent binary(16)
      declare @parent_id_ss_start int
      declare @parent_id_schedule_start int
      declare @svctablename nvarchar(255)
      declare @total_sess int
      declare @id_max_sess int
      declare @bucket int
      declare @child_ss_start int
      declare @diff int
      declare @numParentsInMessage int
      declare @i int
      declare @j int
      SET @return_code = 0
      create table #t_svc_relations (
			      id_svc int primary key,
			      parent_id_svc int)
      create table #aggregate_large(
	      id_sess int identity(1,1) not null PRIMARY KEY,
	      id_parent_source_sess binary(16),
	      sessions_in_compound int)
	    create table #aggregate(
	      id_sess int identity(1,1),
	      id_parent_source_sess binary(16),
	      sessions_in_compound int)           
      set @sql = N'insert into #t_svc_relations (id_svc, parent_id_svc)
		      select distinct id_svc, null from ' + @rerun_table_name +
		      N' where id_parent_source_sess is null'
      EXEC sp_executesql @sql
      set @sql = N'insert into #t_svc_relations (id_svc, parent_id_svc)
			      select  distinct child.id_svc, parent.id_svc
			      from ' + @rerun_table_name + N' child
			      inner join ' + @rerun_table_name + N' parent
			      on child.id_parent_source_sess = parent.id_source_sess'
      EXEC sp_executesql @sql
      select * from #t_svc_relations
      DECLARE tablename_cursor CURSOR FOR
	      select id_svc from #t_svc_relations
	      where parent_id_svc is null
	      OPEN tablename_cursor
	      FETCH NEXT FROM tablename_cursor into @id_svc
      WHILE @@FETCH_STATUS = 0
      BEGIN
        -- Bug Fix: 13270, id_svc can be more than 9999, changing size of varchar from 4 to 6
	      PRINT 'the service considered is: ' + cast(@id_svc as varchar(6))
	      -- Bug Fix: 12614 Check to see if all sessions of this parent service exist in the
	      -- corresponding service def table. If the counts are not same, throw 
	      -- an error.
	      set @svctablename = (select nm_table_name from t_service_def_log slog
				    inner join t_enum_data ed
				    on slog.nm_service_def = ed.nm_enum_data
				    where ed.id_enum_data = @id_svc)	
	      set @sql = N'select @num_parent_sessions = count(*) from ' +
			            @rerun_table_name +
			            N' rr where rr.id_svc = ' +
			            cast(@id_svc as nvarchar(6)) +
			            N' and rr.id_parent_source_sess is null'
        select @args = N'@num_parent_sessions INT OUTPUT'
	      exec sp_executesql @sql, @args, @num_parent_sessions OUTPUT
       	set @sql = N'select @num_service_sessions = count(*) from ' +
			              @rerun_table_name +
			              N' rr inner join ' +
			              @svctablename +
			              N' svc on rr.id_source_sess = svc.id_source_sess where rr.id_svc = ' +
			             cast(@id_svc as nvarchar(6))
	      select @args = N'@num_service_sessions INT OUTPUT'
	      exec sp_executesql @sql, @args, @num_service_sessions OUTPUT
	      if (@num_service_sessions < @num_parent_sessions)
	      begin
		      set @return_code = -100 --one or more sessions that have been identified for resubmission are missing.
		      GOTO FATALERROR
	      end
	      -- insert into the aggregate table details of compounds for this svc
	      -- if this a parent of a compound 
	      declare @numChildrenSvc int
	      select @numChildrenSvc = count(*)
	      from #t_svc_relations
	      where parent_id_svc = @id_svc
	      if (@numChildrenSvc > 0)
	      BEGIN
	
			    -- you could have some parents with no children at all (CR13174) which
			    -- would be missed in the original inner join. Changing the inner join
			    -- to left outer and adding the case statement fixes that.
			    
		      set @sql = N'insert into #aggregate
			      select  rr_parent.id_source_sess, sum(case when rr_child.id_source_sess is null then 0 else 1 end) + 1
			      from ' + @rerun_table_name + N' rr_parent
			      left join ' + @rerun_table_name + N' rr_child
			      on rr_parent.id_source_sess = rr_child.id_parent_source_sess
			      where rr_parent.id_parent_source_sess is null
			      and rr_parent.id_svc = ' + cast(@id_svc as nvarchar(6)) + 
			      N' and rr_parent.tx_state = ''B''
			      group by rr_parent.id_source_sess
			      having count(*) < 1000'
	          EXEC sp_executesql @sql
			      set @sql = N'insert into #aggregate_large
			      select  rr_parent.id_source_sess, count(*) + 1
			      from ' + @rerun_table_name + N' rr_parent
			      inner join ' + @rerun_table_name + N' rr_child
			      on rr_parent.id_source_sess = rr_child.id_parent_source_sess
			      where rr_parent.id_parent_source_sess is null
			      and rr_parent.id_svc = ' + cast(@id_svc as nvarchar(6)) + 
			      N' and rr_parent.tx_state = ''B''
			      group by rr_parent.id_source_sess
			      having count(*) >= 1000'	
			      
			      EXEC sp_executesql @sql	      
			      
	      END
	      ELSE
	      begin
 	            
		        set @sql = N'insert into #aggregate
			                    select id_source_sess, 1
			                    from ' + @rerun_table_name + 
			                    N' where id_svc = ' + cast(@id_svc as nvarchar(6)) +
			                    N' and tx_state = ''B'''
			                    
            EXEC sp_executesql @sql			                    
	      end

	      if ((select MAX(sessions_in_compound) from #aggregate_large) > @maxsize)
	      begin
		      set @return_code = -517996536 --one compound is larger than the entire message size
	      end

	      -- update the t_svc table's _intervalID (Bug Fix for 12173)
                     set @sql = N'select @j = max(id) from ' + @rerun_table_name 
 	     select @args = N'@j INT OUTPUT'

	     exec sp_executesql @sql, @args, @j OUTPUT
             
	     set @i=1
                     while (@i <= @j)
                     begin
                     set @sql = N'update svc
                       		set svc.c__IntervalId = rr.id_interval
                       		from ' + @rerun_table_name + N' rr 
                       		inner join ' + @svctablename + N' svc
                      		on rr.id_source_sess = svc.id_source_sess
                      		inner join t_usage_interval ui
                      		on ui.id_interval = rr.id_interval
                      		inner join t_acc_usage_interval aui
                      		on aui.id_acc = rr.id_payer and
                      		   aui.id_usage_interval = rr.id_interval
                       		where rr.id_interval is not null 
                       		and	aui.tx_status = ''C''
                       		and rr.id between ' + cast(@i as nvarchar(10)) + N' and ' + cast(@i+999999 as nvarchar(10))
                       		
													exec sp_executesql @sql  
	                        set @i = @i + 1000000
                     end

	      if (select count(*) from #aggregate_large) > 0
	      begin

			declare @total_large int
			declare @total_child_session_sets int
			select @total_large = max(id_sess) from #aggregate_large
			select @id_ss_start = id_current from t_current_id with(updlock) where nm_current='id_dbqueuess'
		        select @id_schedule_start = id_current from t_current_id with(updlock) where nm_current='id_dbqueuesch'
	             
			--set @parent_id_ss_start = @id_ss_start
			--set @parent_id_schedule_start = @id_schedule_start

			insert into t_session (id_ss, id_source_sess) 
		              select id_sess + @id_ss_start, id_parent_source_sess 
			            from #aggregate_large

			insert into t_session_set (id_ss, id_message, id_svc, session_count, b_root) 
		              select id_sess + @id_ss_start, id_sess + @id_schedule_start, @id_svc, 1, 1
			            from #aggregate_large
    			         
			insert into t_message(id_message, id_route, dt_crt, dt_assigned, 
			        id_listener, id_pipeline, dt_completed, id_feedback, dt_metered, tx_sc_serialized, tx_ip_address) 
			         select  id_message, null, cast(@metradate as datetime), null, null, null, 
			         null, null, cast(@metradate as datetime), @context, '127.0.0.1'
			         from t_session_set WITH (READCOMMITTED)
			         where id_message > @id_schedule_start 

	                -- create child session sets
			create table #child_session_sets
			(
				id_sess int identity(1, 1),
				id_parent_sess int not null,
				id_svc int not null,
				cnt int
			)
			Alter table #child_session_sets
				add constraint pk_child_session_sets
				PRIMARY KEY (id_parent_sess, id_svc)


			set @sql = N'insert into #child_session_sets (id_parent_sess, id_svc, cnt)
				select prnt.id_sess , rr.id_svc, count(*)
				from ' +	
				@rerun_table_name + N' rr
				inner join #aggregate_large prnt on prnt.id_parent_source_sess=rr.id_parent_source_sess
				group by prnt.id_sess, rr.id_svc'

			EXEC sp_executesql @sql

			select * from #child_session_sets
			select @total_child_session_sets = max(id_sess) from #child_session_sets

			insert into t_session_set (id_ss, id_message, id_svc, session_count, b_root) 
				select id_sess + @total_large + @id_ss_start, id_parent_sess + @id_schedule_start, id_svc, cnt, 0
				from #child_session_sets

			set @sql = N'insert into t_session (id_ss, id_source_sess) 
				select css.id_sess + ' + cast(@total_large as nvarchar(15)) + N' + ' + cast(@id_ss_start as nvarchar(15))+
				+ N' , rr.id_source_sess
				from ' + @rerun_table_name + N' rr
				inner join #aggregate_large prnt on prnt.id_parent_source_sess=rr.id_parent_source_sess
				inner join #child_session_sets css on css.id_parent_sess=prnt.id_sess and css.id_svc=rr.id_svc'

			EXEC sp_executesql @sql
		       
			update t_current_id 
		            set id_current = id_current + @total_large + @total_child_session_sets + 1
		            where nm_current='id_dbqueuess'
    		        
		        update t_current_id 
		            set id_current = id_current + @total_large + 1
		            where nm_current='id_dbqueuesch'	
				
			
	                truncate table #aggregate_large
			drop table #child_session_sets
	              
        end -- if we have compounds with more than 100 children   
        if (select count(*) from #aggregate) > 0
        begin    -- dealing with atomics or with compounds with less than 100 children
          if (@numChildrenSvc > 0)	 -- compounds with children less than 100, 
          begin
                select @total_sess = sum(sessions_in_compound), @id_max_sess = max(id_sess) from #aggregate
		
                if (@total_sess > @maxsize)
                begin
          	      select @numParentsInMessage = @maxsize/AVG(sessions_in_compound) from #aggregate
			            print ' the @numParentsInMessage is: ' + cast(@numParentsInMessage as varchar(4)) 
          	      set @bucket = @id_max_sess/@numParentsInMessage + 1
          	    end  
          	    else
          	      set @bucket = 1    
          	      
          	    select @id_ss_start = id_current from t_current_id with(updlock) 
		                              where nm_current='id_dbqueuess'
		            select @id_schedule_start = id_current from t_current_id with(updlock) 
		                                    where nm_current='id_dbqueuesch'
                
		            set @parent_id_ss_start = @id_ss_start
		            set @parent_id_schedule_start = @id_schedule_start
		              		                                    
	              insert into t_session (id_ss, id_source_sess) 
		            select (id_sess%@bucket)+ @id_ss_start, id_parent_source_sess 
			            from #aggregate
	
				        insert into t_session_set(id_ss, id_message, id_svc, session_count, b_root)
			          select id_ss, (id_ss%@bucket) + @id_schedule_start, @id_svc, count(*), 1
			          from t_session WITH (READCOMMITTED)
			          where id_ss >= @id_ss_start and id_ss < @id_ss_start+@bucket
			          group by id_ss
    			        
			          insert into t_message(id_message, id_route, dt_crt, dt_assigned, 
			          id_listener, id_pipeline, dt_completed, id_feedback, dt_metered, tx_sc_serialized, tx_ip_address) 
			          select  id_message, null, cast(@metradate as datetime), null, null, null, 
			          null, null, cast(@metradate as datetime), @context, '127.0.0.1'
			          from t_session_set WITH (READCOMMITTED)
			          where id_message >= @id_schedule_start and id_message < @id_schedule_start+@bucket
   
                update t_current_id 
		            set id_current = id_current + @bucket
		            where nm_current='id_dbqueuess'
    		        
		            update t_current_id 
		            set id_current = id_current + @bucket
		            where nm_current='id_dbqueuesch'	

   				
                -- add sessions for each child type
                DECLARE Children_cursor CURSOR for
		            select id_svc from #t_svc_relations where parent_id_svc = @id_svc
		            OPEN Children_cursor
		            FETCH NEXT FROM Children_cursor into @child_svc
		            WHILE @@FETCH_STATUS = 0
		            BEGIN
			            --PRINT 'dealing with child service: ' + cast (@child_svc as varchar(4))
			            select @id_ss_start = id_current from t_current_id with(updlock) where nm_current='id_dbqueuess'

			            select @diff = @id_ss_start - @parent_id_ss_start

	            select @child_ss_start = @id_ss_start
					            
			            set @sql = N'insert into t_session (id_ss, id_source_sess)
				            select id_ss + ' + cast(@diff as nvarchar(10)) +  N' , rr.id_source_sess
				            from ' + @rerun_table_name + N' rr
				            inner join t_session ss WITH (READCOMMITTED)
				            on ss.id_source_sess = rr.id_parent_source_sess
				            where ss.id_ss >= ' + cast(@parent_id_ss_start as nvarchar(10)) +
				            N' and ss.id_ss < ' + cast(@id_ss_start as nvarchar(10)) +
				            N' and rr.id_svc = ' + cast(@child_svc as nvarchar(4))
			            EXEC sp_executesql @sql

                  update t_current_id
                    set id_current = (select max(id_ss) from t_session) + 1
                    where nm_current='id_dbqueuess'
                    
                  select @id_ss_start = id_current from t_current_id 
                    where nm_current='id_dbqueuess'

     
			            set @sql = N'insert into t_session_set(id_ss, id_message, id_svc, session_count, b_root)
				            select ss.id_ss , parentset.id_message, ' + cast(@child_svc as nvarchar(4)) + N', count(*), ''0''
				            from t_session ss WITH (READCOMMITTED)
				            inner join ' + @rerun_table_name + N' rr
				            on ss.id_source_sess = rr.id_source_sess
				            left outer join t_session parent WITH (READCOMMITTED)
				            on parent.id_source_sess = rr.id_parent_source_sess
				            left outer join t_session_set parentset WITH (READCOMMITTED)
				            on parentset.id_ss = parent.id_ss
				            where ss.id_ss >= ' + cast(@child_ss_start as nvarchar(10))
				            + N' and ss.id_ss < ' + cast(@id_ss_start as nvarchar(10))
					    + N' and parentset.id_message >= ' + cast(@parent_id_schedule_start as nvarchar(10))
				            + N' group by ss.id_ss, parentset.id_message'

                  EXEC sp_executesql @sql
	                  
			            FETCH NEXT FROM Children_cursor into @child_svc
		            END
		            CLOSE Children_cursor
		            DEALLOCATE Children_cursor
	              IF OBJECT_ID('tempdb..#aggregate') IS NOT NULL 
		            truncate table #aggregate		                                      
            	    
          end
          else -- finally, just the atomics!	  
          begin    
		          select @id_max_sess=max(id_sess) from #aggregate
    		      
			        if (@id_max_sess > @maxsize)
			         begin 
			           if @id_max_sess%@maxsize = 0
			            set @bucket = @id_max_sess/@maxsize
			           else 
			            set @bucket = @id_max_sess/@maxsize + 1
			         end 
			        else set @bucket=1
    			    
		          select @id_ss_start = id_current from t_current_id with(updlock) 
		                                where nm_current='id_dbqueuess'
		          select @id_schedule_start = id_current from t_current_id with(updlock) 
		                                      where nm_current='id_dbqueuesch'
		          insert into t_session (id_ss, id_source_sess) 
		              select (id_sess%@bucket)+ @id_ss_start, id_parent_source_sess 
			            from #aggregate
    			        
		          insert into t_session_set(id_ss, id_message, id_svc, session_count, b_root)
			            select id_ss, (id_ss%@bucket) + @id_schedule_start, @id_svc, count(*), 1
			            from t_session  WITH (READCOMMITTED)
			            where id_ss >= @id_ss_start and id_ss < @id_ss_start+@bucket
			            group by id_ss
    			         
			        insert into t_message(id_message, id_route, dt_crt, dt_assigned, 
			            id_listener, id_pipeline, dt_completed, id_feedback, dt_metered, tx_sc_serialized, tx_ip_address) 
			            select  id_message, null, cast(@metradate as datetime), null, null, null, 
			            null, null, cast(@metradate as datetime), @context, '127.0.0.1'
			            from t_session_set  WITH (READCOMMITTED)
			            where id_message >= @id_schedule_start and id_message < @id_schedule_start+@bucket

		          update t_current_id 
		            set id_current = id_current + @bucket
		            where nm_current='id_dbqueuess'
    		        
		          update t_current_id 
		            set id_current = id_current + @bucket
		            where nm_current='id_dbqueuesch'	
    		        
		          IF OBJECT_ID('tempdb..#aggregate') IS NOT NULL 
		            truncate table #aggregate
          end
        end
        	              
	      FETCH NEXT FROM tablename_cursor into @id_svc
	      END -- end iterating over all parents services in the t_rerun_session table

	      CLOSE tablename_cursor
	      DEALLOCATE tablename_cursor

	      IF OBJECT_ID('tempdb..#aggregate') IS NOT NULL 
		      DROP table #aggregate
		      IF OBJECT_ID('tempdb..#aggregate_large') IS NOT NULL 
		      DROP table #aggregate_large
	      IF OBJECT_ID('tempdb..#t_svc_relations') IS NOT NULL 
		      DROP table #t_svc_relations

	      --adjust the session state
	      declare @mtmaxdate nvarchar(30) 
	      set @mtmaxdate = convert(nvarchar(30), dbo.MTMaxDate(), 100) 	
	      set @sql = N'update t_session_state
		        set dt_end =  ''' + @metradate + N'''
		        from ' + @rerun_table_name + N' rr
		      inner join t_session_state ss
		      on rr.id_source_sess = ss.id_sess
		      where ss.dt_end = ''' + @mtmaxdate +N'''
		      and rr.tx_state = ''B'' '

	      EXEC sp_executesql @sql


	      set @sql = N'INSERT INTO t_session_state (id_sess, dt_start, dt_end, tx_state) 
		        SELECT rr.id_source_sess, ''' + @metradate + N''', ''' + @mtmaxdate + N''', ''R''
		        from ' + @rerun_table_name + N' rr
		        where rr.tx_state = ''B'' '

	      EXEC sp_executesql @sql

	      --mark the records that were submitted to 'R' in t_failed_transaction
	      set @sql = N'update ft
	                    set State = ''R'',
	                    dt_StateLastModifiedTime = ''' + @metradate +
	                    N''' from ' + @rerun_table_name + N' rr
	                    inner join t_failed_transaction ft
	                    on rr.id_source_sess = ft.tx_failureID
	                    where rr.tx_state = ''B'''
	   	 
	   	  EXEC sp_executesql @sql	              

	      return @return_code

      FATALERROR: IF OBJECT_ID('tempdb..#t_svc_relations') IS NOT NULL 
		      DROP table #t_svc_relations
	          IF OBJECT_ID('tempdb..#aggregate') IS NOT NULL 
		      DROP table #aggregate
		  IF (@return_code = 0)
			SET @return_code = -1
	          return @return_code

      end

       