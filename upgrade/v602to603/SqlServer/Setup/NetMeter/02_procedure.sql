SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

PRINT N'Altering [dbo].[Analyze]'
GO

ALTER PROCEDURE Analyze (@table_name nvarchar(30))
    as
    begin
	  declare @rows_changed int
	  declare @query nvarchar(4000)
	  declare @svctablename nvarchar(255)
	  declare @id_svc nvarchar(10)
    declare @reanalyze_index int
     
	  -- mark the successful rows as analyzed.
		if exists (select 1 from t_usage_server where b_partitioning_enabled = 'N')
		begin
      
     -- clean up any rows in the t_rerun_table that may have been alterd
	   -- ReAnalyze Case. This will al
		  SELECT @reanalyze_index =  CHARINDEX(UPPER('t_rerun_session_'), UPPER(@table_name))

	    if (@reanalyze_index != 0)
	      begin
      		  set @query = N'delete from ' + @table_name + 
			  ' where id_source_sess not in  ((select id_source_sess from ' + @table_name + ' rr inner join t_acc_usage au on rr.id_source_sess = au.tx_UID)
			    union (select id_source_sess from ' + @table_name + ' rr inner join t_failed_transaction tft on rr.id_source_sess = tft.tx_FailureID))'

			  EXEC sp_executesql @query
	  	end
      
				set @query = N'update ' + @table_name +
					N' set tx_state = ''A''
					from ' + @table_name + N' rr
					inner join t_acc_usage acc
					on rr.id_sess = acc.id_sess
					and acc.id_usage_interval = rr.id_interval
					where tx_state = ''I'''
		end
		else
		begin
				set @query = N'update ' + @table_name +
					N' set tx_state = ''A''
					from ' + @table_name + N' rr
					inner join t_uk_acc_usage_tx_uid acc
					on rr.id_source_sess = acc.tx_uid
					where tx_state = ''I'''
		end
	  EXEC sp_executesql @query
	  
	  -- set the id_parent_source_sess correctly for the children already 
	  -- identified by now (successful only)
	 
	  set @query = N'update ' + @table_name +
		  N' set id_parent_source_sess = acc.tx_uid
		  from ' + @table_name + N' rr
		  inner join t_acc_usage acc
		  on rr.id_parent_sess = acc.id_sess
		  and acc.id_usage_interval = rr.id_interval
		  where acc.id_parent_sess is null
		  and rr.id_parent_source_sess is null
		  and rr.tx_state = ''A'''
    EXEC sp_executesql @query
    
	  -- just so the loop will run the first time
	  set @rows_changed = 1

		-- find parents for successful sessions
		set @query = N'
		insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
		  select distinct 
			auparents.tx_UID,	-- id_source_sess
			auparents.tx_batch,	-- tx_batch
			auparents.id_sess,	-- id_sess
			auparents.id_parent_sess,	-- id_parent
			null,				-- TODO: root
			auparents.id_usage_interval,	-- id_interval
			auparents.id_view,		-- id_view
			case aui.tx_status when ''H'' then ''C'' else ''A'' end, -- c_state
			auparents.id_svc,		-- id_svc
			NULL, -- id_parent_source_sess
			auparents.id_acc,
			auparents.amount,
			auparents.am_currency
		  from t_acc_usage auchild
		  inner join ' + @table_name + N' rr on auchild.id_sess = rr.id_sess
  		  and auchild.id_usage_interval =rr.id_interval
		  inner join t_acc_usage auparents on auparents.id_sess = auchild.id_parent_sess
		  and auparents.id_usage_interval =auchild.id_usage_interval
		  inner join t_acc_usage_interval aui on auparents.id_usage_interval = aui.id_usage_interval
        and auparents.id_acc = aui.id_acc
		  where not exists (select * from ' + @table_name + N' rr1 where rr1.id_sess = auparents.id_sess and auparents.id_usage_interval =rr1.id_interval)'
		EXEC sp_executesql @query

		-- find children for successful sessions
		set @query = N'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, 
				root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
		  select
			au.tx_UID,	-- id_source_sess
			au.tx_batch,	-- tx_batch
			au.id_sess,	-- id_sess
			au.id_parent_sess,	-- id_parent
			null,			-- TODO: root
			au.id_usage_interval,	-- id_interval
			au.id_view,		-- id_view
			case aui.tx_status when ''H'' then ''C'' else ''A'' end,			-- tx_state
			au.id_svc,	-- id_svc
			rr.id_source_sess, -- id_parent_source_sess
			au.id_acc,
			au.amount,
			au.am_currency
			from t_acc_usage au
			inner join ' + @table_name + N' rr on au.id_parent_sess = rr.id_sess
			and au.id_usage_interval = rr.id_interval
			inner join t_acc_usage_interval aui on au.id_usage_interval = aui.id_usage_interval
         and au.id_acc = aui.id_acc
			where not exists (select 1 from ' + @table_name + N' rr1 where rr1.id_sess = au.id_sess
			and rr1.id_interval = au.id_usage_interval)'
		EXEC sp_executesql @query

	 set @rows_changed = 1
	 -- complete the compound for failure cases.  In t_failed_transaction, you will have only the failed
	 -- portion of the failed transaction.
	 while (@rows_changed > 0)
	 begin
		set @rows_changed = 0
		-- find children for failed parent sessions
		-- find tables where children may live.
	  create table #tmpcursor1 (nm_table_name nvarchar(255), id_enum_data int)
	  set @query = N'insert into #tmpcursor1 (nm_table_name, id_enum_data)
			select distinct slog.nm_table_name, ed.id_enum_data
			from ' + @table_name + N'  rr
			inner join t_failed_transaction ft WITH (READCOMMITTED)
			on (rr.id_source_sess = ft.tx_failureCompoundID)
			inner join t_session_set ss WITH (READCOMMITTED)
			on ss.id_ss = ft.id_sch_ss
			inner join t_session_set childss WITH (READCOMMITTED)
			on ss.id_message = childss.id_message
			inner join t_enum_data ed
			on ed.id_enum_data = childss.id_svc
			inner join t_service_def_log slog
			on ed.nm_enum_data = slog.nm_service_def
			where id_parent_source_sess is null and tx_state = ''E''
			and childss.b_root = ''0'''
	  EXEC sp_executesql @query
		DECLARE tablename_cursor CURSOR FOR select nm_table_name, id_enum_data from #tmpcursor1
		OPEN tablename_cursor
		FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @svctablename
			set @query = 'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
			select 
			conn.id_source_sess,	-- id_source_sess
			conn.c__CollectionID,	-- tx_batch
			NULL,	-- id_sess
			NULL,	-- id_parent_sess
			NULL,			-- TODO: root
			NULL,	-- id_interval
			NULL,		-- id_view
			''E'',			-- tx_state
			'+ @id_svc + N' , 	-- id_svc
			conn.id_parent_source_sess,
			null, -- id_payer
			null, -- amount
			null -- currency
			from ' + @table_name + N' rr
			inner join ' + @svctablename + N' conn WITH (READCOMMITTED)
			on rr.id_source_sess = conn.id_parent_source_sess
			where rr.id_parent_source_sess is null and tx_state = ''E''
			and not exists (select * from ' + @table_name + N' where ' +  @table_name + '.id_source_sess = conn.id_source_sess)'
			EXEC sp_executesql @query
			set @rows_changed = @rows_changed + @@ROWCOUNT
			FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		END
		CLOSE tablename_cursor
		DEALLOCATE tablename_cursor
    drop table #tmpcursor1
    		-- find parents for failed children sessions
		-- this query gives us all the svc tables in which the parents may live
	  create table #tmpcursor2 (nm_table_name nvarchar(255), id_enum_data int)
	  set @query =  N'insert into #tmpcursor2(nm_table_name, id_enum_data)
			select distinct slog.nm_table_name, cast(ed.id_enum_data as nvarchar(10))
			from ' + @table_name + N' rr
			inner join t_failed_transaction ft WITH (READCOMMITTED)
			on rr.id_source_sess = ft.tx_failureID
			inner join t_session_set ss WITH (READCOMMITTED)
			on ss.id_ss = ft.id_sch_ss
			inner join t_session_set parentss WITH (READCOMMITTED)
			on ss.id_message = parentss.id_message
			inner join t_enum_data ed
			on ed.id_enum_data = parentss.id_svc
			inner join t_service_def_log slog
			on ed.nm_enum_data = slog.nm_service_def
			where id_parent_source_sess is not null
			and tx_state = ''E''
			and ss.id_svc <> parentss.id_svc
			and parentss.b_root = ''1'''
	  EXEC sp_executesql @query
 		DECLARE tablename_cursor CURSOR FOR select nm_table_name, id_enum_data from #tmpcursor2
		OPEN tablename_cursor
		FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @svctablename
			set @query = 'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
			select 
			call.id_source_sess,	-- id_source_sess
			call.c__CollectionID,	-- tx_batch
			NULL,	-- id_sess
			NULL,	-- id_parent_sess
			NULL,			-- TODO: root
			NULL,	-- id_interval
			NULL,		-- id_view
			''E'',			-- tx_state 
			'+ @id_svc + N' , 	-- id_svc
			call.id_parent_source_sess,
			null, -- id_payer
		  null, -- amount
		  null  -- currency
			from ' + @table_name + N' rr
			inner join ' + @svctablename + N' call WITH (READCOMMITTED)
			on rr.id_parent_source_sess = call.id_source_sess
			where rr.id_parent_source_sess is not null and tx_state = ''E''
			and not exists (select * from ' + @table_name + N' where ' +  @table_name + '.id_source_sess = call.id_source_sess)'
			EXEC sp_executesql @query
			set @rows_changed = @rows_changed + @@ROWCOUNT
			FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		END
		CLOSE tablename_cursor
		DEALLOCATE tablename_cursor
    DROP TABLE #tmpcursor2
	 end
	-- handle suspended and pending transactions.  We know we will have identified
	-- all suspended and pending parents.  Only children need to be looked at.
	-- following query tells us which tables to look for the children
	-- changing the cursor query.. for whatever reason,it takes too long, even when there are 
	-- no suspended transactions (CR: 13059)
	create table #tmpcursor3 (nm_table_name nvarchar(255), id_enum_data int)
	set @query =  N'insert into #tmpcursor3(nm_table_name, id_enum_data)
			select distinct slog.nm_table_name , cast(ss2.id_svc as nvarchar(10))
			from t_session_set ss2 WITH (READCOMMITTED)
			inner join t_enum_data ed
			on ss2.id_svc = ed.id_enum_data
			inner join t_service_def_log slog
			on ed.nm_enum_data = slog.nm_service_def
			where id_message in (
			select ss.id_message from '+ @table_name + N' rr
			inner join t_session sess WITH (READCOMMITTED)
			on sess.id_source_sess = rr.id_source_sess
			inner join t_session_set ss WITH (READCOMMITTED)
			on sess.id_ss = ss.id_ss
			inner join t_message msg WITH (READCOMMITTED)
			on msg.id_message = ss.id_message
			where rr.tx_state = ''NC'')
			and ss2.b_root = ''0'''
		EXEC sp_executesql @query
		DECLARE tablename_cursor CURSOR FOR select nm_table_name, id_enum_data from #tmpcursor3
		OPEN tablename_cursor
		FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @query = N'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
				select svc.id_source_sess, null, 
				null, null, null, null, null, ''NA'', '
				+ cast(@id_svc as nvarchar(10)) + N' , rr.id_source_sess, null, null, null
				from ' + @table_name + N' rr
				inner join ' + @svctablename + N' svc WITH (READCOMMITTED)
				on rr.id_source_sess = svc.id_parent_source_sess
				where rr.tx_state = ''NC''
				and svc.id_source_sess not in (select id_source_sess from ' + @table_name +')'
			EXEC sp_executesql @query
			FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		END
		CLOSE tablename_cursor
		DEALLOCATE tablename_cursor
		set @query = N'update ' + @table_name + N'
			set tx_state = ''NA'' where
			tx_state = ''NC'''
		EXEC sp_executesql @query
		DROP TABLE #tmpcursor3
  end

GO




ALTER procedure MoveAccount 
	(@new_parent int,
	 @account_being_moved int,
   @vt_move_start datetime,
   @p_enforce_same_corporation varchar,
   @status int output,
   @p_id_ancestor_out int output,
   @p_ancestor_type varchar(40) output,
   @p_acc_type varchar(40) output)
as
begin
declare @vt_move_end datetime
set @vt_move_end = dbo.MTMaxDate()

declare @vt_move_start_trunc datetime
set @vt_move_start_trunc = dbo.MTStartOfDay(@vt_move_start)

-- plug business rules back in
declare @varMaxDateTime as datetime
declare @AccCreateDate as datetime
declare @AccMaxCreateDate as datetime
declare @p_dt_start datetime
declare @realstartdate as datetime
declare @p_id_ancestor as int
declare @p_id_descendent as int
declare @ancestor_acc_type as int
declare @descendent_acc_type as int


set @p_dt_start = @vt_move_start_trunc
set @p_id_ancestor = @new_parent
set @p_id_descendent = @account_being_moved


select @realstartdate = dbo.mtstartofday(@p_dt_start) 
select @varMaxDateTime = max(vt_end) from t_account_ancestor with (updlock) where id_descendent = @p_id_descendent
and id_ancestor = 1

select @AccCreateDate = dbo.mtminoftwodates(dbo.mtstartofday(ancestor.dt_crt),dbo.mtstartofday(descendent.dt_crt)),
@ancestor_acc_type = ancestor.id_type,
@descendent_acc_type = descendent.id_type
from t_account ancestor with (updlock)
inner join t_account descendent with (updlock) ON 
ancestor.id_acc = @p_id_ancestor and
descendent.id_acc = @p_id_descendent


select @p_ancestor_type = name 
from t_account_type
where id_type = @ancestor_acc_type


select @p_acc_type = name 
from t_account_type
where id_type = @descendent_acc_type


--begin business rules check

	select @AccMaxCreateDate = 
	dbo.mtmaxoftwodates(dbo.mtstartofday(ancestor.dt_crt),dbo.mtstartofday(descendent.dt_crt))
	from t_account ancestor,t_account descendent where ancestor.id_acc = @p_id_ancestor and
	descendent.id_acc = @p_id_descendent
	if dbo.mtstartofday(@p_dt_start) < dbo.mtstartofday(@AccMaxCreateDate)  begin
		-- MT_CANNOT_MOVE_ACCOUNT_BEFORE_START_DATE
		select @status = -486604750
		return
	end 
	
	-- step : make sure that the new ancestor is not actually a child
	select @status = count(*) 
	from t_account_ancestor 
	where id_ancestor = @p_id_descendent 
	and id_descendent = @p_id_ancestor AND 
  	@realstartdate between vt_start AND vt_end
	if @status > 0 
   	begin 
		-- MT_NEW_PARENT_IS_A_CHILD
	 select @status = -486604797
	 return
  	end 

	select @status = count(*) 
	from t_account_ancestor 
	where id_ancestor = @p_id_ancestor 
	and id_descendent = @p_id_descendent 
	and num_generations = 1
	and @realstartdate >= vt_start 
	and vt_end = @varMaxDateTime
	if @status > 0 
	begin 
		-- MT_NEW_ANCESTOR_IS_ALREADY_ A_ANCESTOR
	 select @status = 1
	 return
	end 


      -- step : make sure that the account is not archived or closed
	select @status = count(*)  from t_account_state 
	where id_acc = @p_id_Descendent
	and (dbo.IsClosed(@status) = 1 OR dbo.isArchived(@status) = 1) 
	and @realstartdate between vt_start AND vt_end
	if (@status > 0 )
	begin
	   -- OPERATION_NOT_ALLOWED_IN_CLOSED_OR_ARCHIVED
	select @status = -469368827
	end 

	-- step : make sure that the account is not a corporate account
	--only check next 2 business rules if p_enforce_same_corporation rule is turned on
	if @p_enforce_same_corporation = 1
	begin
		if (dbo.iscorporateaccount(@p_id_descendent,@p_dt_start) = 1)
		-- MT_CANNOT_MOVE_CORPORATE_ACCOUNT
			begin
			select @status = -486604770
			return
			end 
		-- do this check if the original ancestor of the account being moved is not -1 
		-- or the new ancestor is not -1
		declare @originalAncestor integer
		select @originalAncestor = id_ancestor from t_account_ancestor 
			where id_descendent =  @p_id_descendent
			and num_generations = 1
			and @vt_move_start_trunc >= vt_start and @vt_move_start_trunc <= vt_end

		if (@originalAncestor <> -1 AND @p_id_ancestor <> -1 AND dbo.IsInSameCorporateAccount(@p_id_ancestor,@p_id_descendent,@realstartdate) <> 1) begin
			-- MT_CANNOT_MOVE_BETWEEN_CORPORATE_HIERARCHIES
			select @status = -486604759
			return
		end
	end

	--check that both ancestor and descendent are subscriber accounts.  This check has to be recast.. you can 
	-- only move if the new ancestor allows children of type @descendent_acc_type
	if @descendent_acc_type not in (
	select id_descendent_type from t_acctype_descendenttype_map
	where id_type = @ancestor_acc_type)
	BEGIN
	-- MT_ANCESTOR_OF_INCORRECT_TYPE
	select @status = -486604714
	return
	END

	-- check that only accounts whose type says b_canHaveSyntheticRoot is true can have -1 as an ancestor.
	if (@p_id_ancestor = -1)
	BEGIN
	declare @syntheticroot varchar(1)
	select @syntheticroot = b_CanhaveSyntheticRoot from t_account_type where id_type = @descendent_acc_type
	if (@syntheticroot <> '1')
	BEGIN
	--MT_ANCESTOR_INVALID_SYNTHETIC_ROOT
		select @status = -486604713
		return
	END
	END
	--this check is removed in Kona.
	--if(@b_is_ancestor_folder <> '1')
	--BEGIN
	-- MT_CANNOT_MOVE_TO_NON_FOLDER_ACCOUNT
	--select @status = -486604726
	--return
	--END

-- end business rules

--METRAVIEW DATAMART 

declare @tmp_t_dm_account table(id_dm_acc int,id_acc int,vt_start datetime,vt_end datetime)
insert into @tmp_t_dm_account  select * from t_dm_account where id_acc in 
(
select distinct id_descendent from t_account_ancestor where id_ancestor = @account_being_moved
)
--Deleting all the entries from ancestor table
delete from t_dm_account_ancestor where id_dm_descendent in (select id_dm_acc from @tmp_t_dm_account)
delete from t_dm_account where id_dm_acc in (select id_dm_acc from @tmp_t_dm_account)

select 
aa2.id_ancestor,
aa2.id_descendent,
aa2.num_generations,
aa2.b_children,
dbo.MTMaxOfTwoDates(@vt_move_start_trunc, dbo.MTMaxOfTwoDates(dbo.MTMaxOfTwoDates(aa1.vt_start, aa2.vt_start), aa3.vt_start)) as vt_start,
dbo.MTMinOfTwoDates(@vt_move_end, dbo.MTMinOfTwoDates(dbo.MTMinOfTwoDates(aa1.vt_end, aa2.vt_end), aa3.vt_end)) as vt_end,
aa2.tx_path
into #deletethese
from
t_account_ancestor aa1
inner join t_account_ancestor aa2 on aa1.id_ancestor=aa2.id_ancestor and aa1.vt_start <= aa2.vt_end and aa2.vt_start <= aa1.vt_end and aa2.vt_start <= @vt_move_end and @vt_move_start_trunc <= aa2.vt_end
inner join t_account_ancestor aa3 on aa2.id_descendent=aa3.id_descendent and aa3.vt_start <= aa2.vt_end and aa2.vt_start <= aa3.vt_end and aa3.vt_start <= @vt_move_end and @vt_move_start_trunc <= aa3.vt_end
where
aa1.id_descendent=@account_being_moved
and
aa1.num_generations > 0
and 
aa1.vt_start <= @vt_move_end 
and 
@vt_move_start_trunc <= aa1.vt_end
and
aa3.id_ancestor=@account_being_moved

-- select old direct ancestor id
select @p_id_ancestor_out = id_ancestor from #deletethese
where num_generations = 1 and @vt_move_start_trunc between vt_start and vt_end


--select * from #deletethese

-- The four statements of the sequenced delete follow.  Watch carefully :-)
--
-- Create a new interval for the case in which the applicability interval of the update
-- is contained inside the period of validity of the existing interval
-- [------------------] (existing)
--    [-----------] (update)
insert into t_account_ancestor(id_ancestor, id_descendent, num_generations,b_children, vt_start, vt_end,tx_path)
select aa.id_ancestor, aa.id_descendent, aa.num_generations, d.b_children,d.vt_start, d.vt_end,
case when aa.id_descendent = 1 then
    aa.tx_path + d.tx_path
    else
    d.tx_path + '/' + aa.tx_path
    end
from
t_account_ancestor aa
inner join #deletethese d on aa.id_ancestor=d.id_ancestor and aa.id_descendent=d.id_descendent and 
	aa.num_generations=d.num_generations and aa.vt_start < d.vt_start and aa.vt_end > d.vt_end

-- Update end date of existing records for which the applicability interval of the update
-- starts strictly inside the existing record:
-- [---------] (existing)
--    [-----------] (update)
-- or
-- [---------------] (existing)
--    [-----------] (update)
update t_account_ancestor
set
t_account_ancestor.vt_end = dateadd(s, -1, d.vt_start)
--select *
from
t_account_ancestor aa 
inner join #deletethese d on aa.id_ancestor=d.id_ancestor and aa.id_descendent=d.id_descendent and 
	aa.num_generations=d.num_generations and aa.vt_start < d.vt_start and aa.vt_end > d.vt_start

-- Update start date of existing records for which the effectivity interval of the update
-- ends strictly inside the existing record:
--              [---------] (existing)
--    [-----------] (update)
update t_account_ancestor
set
t_account_ancestor.vt_start = dateadd(s, 1, d.vt_end)
--select *
from
t_account_ancestor aa 
inner join #deletethese d on aa.id_ancestor=d.id_ancestor and aa.id_descendent=d.id_descendent and 
	aa.num_generations=d.num_generations and aa.vt_start <= d.vt_end and aa.vt_end > d.vt_end

-- Delete existing records for which the effectivity interval of the update
-- contains the existing record:
--       [---------] (existing)
--     [---------------] (update)
delete aa
--select *
from
t_account_ancestor aa 
inner join #deletethese d on aa.id_ancestor=d.id_ancestor and aa.id_descendent=d.id_descendent and 
	aa.num_generations=d.num_generations and aa.vt_start >= d.vt_start and aa.vt_end <= d.vt_end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- SEQUENCED INSERT JOIN
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Now do the sequenced insert into select from with the sequenced
-- cross join as the source of the data.

insert into t_account_ancestor(id_ancestor, id_descendent, num_generations,b_children, vt_start, vt_end,tx_path)
select aa1.id_ancestor, 
aa2.id_descendent, 
aa1.num_generations+aa2.num_generations+1 as num_generations,
aa2.b_children, 
dbo.MTMaxOfTwoDates(@vt_move_start_trunc, dbo.MTMaxOfTwoDates(aa1.vt_start, aa2.vt_start)) as vt_start,
dbo.MTMinOfTwoDates(@vt_move_end, dbo.MTMinOfTwoDates(aa1.vt_end, aa2.vt_end)) as vt_end,
case when aa2.id_descendent = 1 then
    aa1.tx_path + aa2.tx_path
    else
    aa1.tx_path + '/' + aa2.tx_path
    end
from
t_account_ancestor aa1
inner join t_account_ancestor aa2 with (updlock) on aa1.vt_start < aa2.vt_end and aa2.vt_start < aa1.vt_end and aa2.vt_start < @vt_move_end and @vt_move_start_trunc < aa2.vt_end
where 
aa1.id_descendent = @new_parent 
and 
aa1.vt_start < @vt_move_end 
and 
@vt_move_start_trunc < aa1.vt_end
and 
aa2.id_ancestor = @account_being_moved

-- Implement the coalescing step.
-- TODO: Improve efficiency by restricting the updates to the rows that
-- might need coalesing.
WHILE 1=1
BEGIN
update t_account_ancestor 
set t_account_ancestor.vt_end = (
	select max(aa2.vt_end)
	from
	t_account_ancestor as aa2
	where
	t_account_ancestor.id_ancestor=aa2.id_ancestor
	and
	t_account_ancestor.id_descendent=aa2.id_descendent
	and
	t_account_ancestor.num_generations=aa2.num_generations
	and
	t_account_ancestor.vt_start < aa2.vt_start
	and
	dateadd(s,1,t_account_ancestor.vt_end) >= aa2.vt_start
	and
	t_account_ancestor.vt_end < aa2.vt_end
	and
	t_account_ancestor.tx_path=aa2.tx_path
)
where
exists (
	select *
	from
	t_account_ancestor as aa2
	where
	t_account_ancestor.id_ancestor=aa2.id_ancestor
	and
	t_account_ancestor.id_descendent=aa2.id_descendent
	and
	t_account_ancestor.num_generations=aa2.num_generations
	and
	t_account_ancestor.vt_start < aa2.vt_start
	and
	dateadd(s,1,t_account_ancestor.vt_end) >= aa2.vt_start
	and
	t_account_ancestor.vt_end < aa2.vt_end
	and
	t_account_ancestor.tx_path=aa2.tx_path
)
and id_descendent in (select id_descendent from #deletethese)

IF @@rowcount <= 0 BREAK
END

delete from t_account_ancestor 
where
exists (
	select *
	from t_account_ancestor aa2 with (updlock)
	where
	t_account_ancestor.id_ancestor=aa2.id_ancestor
	and
	t_account_ancestor.id_descendent=aa2.id_descendent
	and
	t_account_ancestor.num_generations=aa2.num_generations
	and
	t_account_ancestor.tx_path=aa2.tx_path
	and
 	(
	(aa2.vt_start < t_account_ancestor.vt_start and t_account_ancestor.vt_end <= aa2.vt_end)
	or
	(aa2.vt_start <= t_account_ancestor.vt_start and t_account_ancestor.vt_end < aa2.vt_end)
	)
)
and id_descendent in (select id_descendent from #deletethese)

	update new set b_Children = 'Y' from t_account_ancestor new where
	id_descendent = @new_parent
	and b_children='N'	

	update old set b_Children = 'N' from t_account_ancestor old where
	id_descendent = @p_id_ancestor_out and
	not exists (select 1 from t_account_ancestor new where new.id_ancestor=old.id_descendent
	and num_generations <>0 )

--DataMart insert new id_dm_acc for moving account and descendents
		insert into t_dm_account(id_acc,vt_start,vt_end) select anc.id_descendent, anc.vt_start, anc.vt_end
		from t_account_ancestor	anc
		inner join @tmp_t_dm_account acc on anc.id_descendent = acc.id_acc
		where anc.id_ancestor=1
		and acc.vt_end = @varMaxDateTime
	
		insert into t_dm_account_ancestor
		select dm2.id_dm_acc, dm1.id_dm_acc, aa1.num_generations
		from
		t_account_ancestor aa1
		inner join t_dm_account dm1 on aa1.id_descendent=dm1.id_acc and aa1.vt_start <= dm1.vt_end and dm1.vt_start <= aa1.vt_end
		inner join t_dm_account dm2 on aa1.id_ancestor=dm2.id_acc and aa1.vt_start <= dm2.vt_end and dm2.vt_start <= aa1.vt_end
		inner join @tmp_t_dm_account acc on aa1.id_descendent = acc.id_acc
		where dm1.id_acc <> dm2.id_acc
		and dm1.vt_start >= dm2.vt_start
		and dm1.vt_end <= dm2.vt_end
		and acc.vt_end = @varMaxDateTime

		--we are adding 0 level record for all children of moving account
		insert into t_dm_account_ancestor select dm1.id_dm_acc,dm1.id_dm_acc,0 	
		from 
		t_dm_account dm1
		inner join @tmp_t_dm_account acc on dm1.id_acc = acc.id_acc
		and acc.vt_end = @varMaxDateTime

select @status=1
END
    
GO

ALTER PROCEDURE CheckForNotClosedDescendents (
	@id_acc INT,
	@ref_date DATETIME,
	@status INT output)
AS
	BEGIN
		select @status = 1
		begin

		-- select accounts that have status less than closed
		SELECT @status =	count(*) 
		FROM 
  		t_account_ancestor aa
			-- join between t_account_state and t_account_ancestor
			INNER JOIN t_account_state astate ON aa.id_descendent = astate.id_acc 
		WHERE
			aa.id_ancestor = @id_acc AND
  		astate.status <> 'CL' AND
  		@ref_date between astate.vt_start and astate.vt_end AND
  		@ref_date between aa.vt_start and aa.vt_end
  		-- success is when no rows found
		if (@status is null)
			   begin
	  select @status = 1
		return
	        end
	  end
	END


GO



ALTER PROCEDURE CheckForNotArchivedDescendents (
	@id_acc INT,
	@ref_date DATETIME,
	@status INT output)
AS

BEGIN
  select @status = 1

	BEGIN

		-- select accounts that have status as closed or archived
		SELECT 
			@status = count(*)  
		FROM 
  		t_account_ancestor aa
			-- join between t_account_state and t_account_ancestor
			INNER JOIN t_account_state astate ON aa.id_descendent = astate.id_acc 
		WHERE
			aa.id_ancestor = @id_acc AND
  		astate.status <> 'AR' AND
  		@ref_date between astate.vt_start and astate.vt_end AND
  		@ref_date between aa.vt_start and aa.vt_end
  		-- success is when no rows found
	IF (@status = 0)
		BEGIN
		  SELECT @status = 1
		RETURN
		END
	END
END

GO

		ALTER proc UpsertDescription
			@id_lang_code int,
			@a_nm_desc NVARCHAR(255),
			@a_id_desc_in int, 
			@a_id_desc int OUTPUT
		AS
		begin
      declare @var int
			IF (@a_id_desc_in IS NOT NULL and @a_id_desc_in <> 0)
				BEGIN
					-- there was a previous entry
				UPDATE t_description
					SET
						tx_desc = ltrim(rtrim(@a_nm_desc))
					WHERE
						id_desc = @a_id_desc_in AND id_lang_code = @id_lang_code

					IF (@@RowCount=0)
					BEGIN
					  -- The entry didn't previously exist for this language code
						INSERT INTO t_description
							(id_desc, id_lang_code, tx_desc)
						VALUES
							(@a_id_desc_in, @id_lang_code, ltrim(rtrim(@a_nm_desc)))
					END

					-- continue to use old ID
					select @a_id_desc = @a_id_desc_in
				END

			ELSE
			  begin
				-- there was no previous entry
				IF (@a_nm_desc IS NULL)
				 begin
					-- no new entry
					select @a_id_desc = 0
				 end
				 ELSE
					BEGIN
						-- generate a new ID to use
						INSERT INTO t_mt_id default values
						select @a_id_desc = @@identity

						INSERT INTO t_description
							(id_desc, id_lang_code, tx_desc)
						VALUES
							(@a_id_desc, @id_lang_code, ltrim(rtrim(@a_nm_desc)))
					 END
			END 
			end

GO



ALTER function checksubscriptionconflicts (
@id_acc            INT,
@id_po             INT,
@real_begin_date   DATETIME,
@real_end_date     DATETIME,
@id_sub            INT
)
RETURNS INT
AS
begin
declare @status int
declare @cycle_type int
declare @po_cycle int

SELECT @status = COUNT (t_sub.id_sub)
FROM t_sub with(updlock)
WHERE t_sub.id_acc = @id_acc
 AND t_sub.id_po = @id_po
 AND t_sub.id_sub <> @id_sub
 AND dbo.overlappingdaterange (t_sub.vt_start,t_sub.vt_end,@real_begin_date,@real_end_date)= 1
IF (@status > 0)
	begin
 -- MTPCUSER_CONFLICTING_PO_SUBSCRIPTION
  RETURN (-289472485)
	END
select @status = dbo.overlappingdaterange(@real_begin_date,@real_end_date,te.dt_start,te.dt_end)
from t_po
INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_eff_date
where id_po = @id_po
if (@status <> 1)
	begin
	-- MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE
	return (-289472472)
	end

SELECT @status = COUNT (id_pi_template)
FROM t_pl_map
WHERE 
  t_pl_map.id_po = @id_po AND
  t_pl_map.id_paramtable IS NULL AND
  t_pl_map.id_pi_template IN
           (SELECT id_pi_template
            FROM t_pl_map
            WHERE 
              id_paramtable IS NULL AND
              id_po IN
                         (SELECT id_po
                            FROM t_vw_effective_subs subs
                            WHERE subs.id_sub <> @id_sub
                            AND subs.id_acc = @id_acc
                             AND dbo.overlappingdaterange (
                                    subs.dt_start,
                                    subs.dt_end,
                                    @real_begin_date,
                                    @real_end_date
                                 ) = 1))
IF (@status > 0)
	begin
	return (-289472484)
	END

-- CR 10872: make sure account and po have the same currency

-- BP - actually we need to check if a payer has different currency
-- In Kona we allow non billable accounts to be created with no currency
--if (dbo.IsAccountAndPOSameCurrency(@id_acc, @id_po) = '0')

if EXISTS
(
SELECT 1 FROM t_payment_redirection pr
INNER JOIN t_av_internal avi on avi.id_acc = pr.id_payer
INNER JOIN t_po po on  po.id_po = @id_po
INNER JOIN t_pricelist pl ON po.id_nonshared_pl = pl.id_pricelist
WHERE pr.id_payee = @id_acc
AND avi.c_currency <>  pl.nm_currency_code
AND (pr.vt_start <= @real_end_date AND pr.vt_end >= @real_begin_date)
)
begin
	-- MT_ACCOUNT_PO_CURRENCY_MISMATCH
	return (-486604729)
end

-- Check for MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 0xEEBF004EL -289472434
-- BR violation
if
  exists (
    SELECT 1
    FROM  t_account tacc 
    INNER JOIN t_account_type tacctype on tacc.id_type = tacctype.id_type
    WHERE tacc.id_acc = @id_acc AND tacctype.b_CanSubscribe = '0'
  )
begin
  return(-289472434) -- MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 
end

-- check that account type of the account is compatible with the product offering
-- since the absense of ANY mappings for the product offering means that PO is "wide open"
-- we need to do 2 EXISTS queries
if
exists (
SELECT 1
FROM t_po_account_type_map atmap 
WHERE atmap.id_po = @id_po
)
--PO is not wide open - see if subscription is permitted for the account type
AND
not exists (
SELECT 1
FROM  t_account tacc 
INNER JOIN t_po_account_type_map atmap on atmap.id_po = @id_po AND atmap.id_account_type = tacc.id_type
 WHERE  tacc.id_acc = @id_acc
)
begin
 return (-289472435) -- MTPCUSER_CONFLICTING_PO_ACCOUNT_TYPE
end


RETURN (1)
END

GO