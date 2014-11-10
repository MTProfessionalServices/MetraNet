
create  procedure MoveAccount 
	(@new_parent int,
	 @account_being_moved int,
   @vt_move_start datetime,
   @p_enforce_same_corporation varchar,
   @p_system_time datetime,
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

--Take update lock very early as we are deadlocking in MoveAccount
declare @old_parent int
declare @varMaxDateTimeAlex datetime
--lock the account to be moved
select @old_parent = id_ancestor
from t_account_ancestor aa with (updlock)
where id_descendent =@account_being_moved and num_generations = 1
--lock old and new parent in a bold sweeping move
--we need it as we will update b_children='Y' on the new parent and b_children='N' on the old parent
select @varMaxDateTimeAlex=max(vt_end) from t_account_ancestor with (updlock)
where id_descendent in ( @old_parent, @new_parent)

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
inner join t_account_ancestor aa2    on aa1.id_ancestor=aa2.id_ancestor 
                                     and aa1.vt_start <= aa2.vt_end 
                                     and aa2.vt_start <= aa1.vt_end 
                                     and aa2.vt_start <= @vt_move_end 
                                     and @vt_move_start_trunc <= aa2.vt_end 
                                     and aa2.id_descendent in (select id_descendent from t_account_ancestor where id_ancestor = @account_being_moved)
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

--Creating index on temp table #deletethese
CREATE UNIQUE CLUSTERED INDEX IX_Clus_idacc_iddesc on #deletethese (id_ancestor, id_descendent)

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

/* update t_path_capabilities */
update pc
set param_value = aa.tx_path + '/'
from
t_account_ancestor aa
inner join #deletethese d on aa.id_descendent=d.id_descendent and aa.id_ancestor = 1
inner join t_principal_policy p on p.id_acc = aa.id_descendent
inner join t_capability_instance ci on ci.id_policy = p.id_policy
inner join t_path_capability pc on ci.id_cap_instance = pc.id_cap_instance
where @p_system_time between aa.vt_start and aa.vt_end

	update new set b_Children = 'Y' from t_account_ancestor new where
	id_descendent = @new_parent
	and b_children='N'

	update old set b_Children = 'N' from t_account_ancestor old where
	id_descendent = @p_id_ancestor_out and
	not exists (select 1 from t_account_ancestor new where new.id_ancestor=old.id_descendent
	and num_generations <>0 )
	-- to avoid update locks only update one that need to be updated
	and b_children = 'Y'
  
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

	-- Process templates after moving account


	DECLARE @allTypesSupported INT
    SELECT @allTypesSupported = all_types
        FROM t_acc_tmpl_types

	SET @allTypesSupported = ISNULL(@allTypesSupported,0)

	DECLARE @templateId INT
	DECLARE @templateOwner INT
	DECLARE @templateType VARCHAR(200)

	select top 1 @templateId = id_acc_template
			, @templateOwner = template.id_folder
			, @templateType = atype.name
	from
				t_acc_template template
	INNER JOIN t_account_ancestor ancestor on template.id_folder = ancestor.id_ancestor
	INNER JOIN t_account_mapper mapper on mapper.id_acc = ancestor.id_ancestor
	inner join t_account_type atype on template.id_acc_type = atype.id_type
			WHERE id_descendent = @new_parent AND
				@p_system_time between vt_start AND vt_end AND
				(atype.name = @p_acc_type OR @allTypesSupported = 1)
	ORDER BY num_generations asc

	DECLARE @sessionId INTEGER
	IF @templateId IS NOT NULL 
	BEGIN
		EXECUTE UpdatePrivateTempates @templateId, @p_system_time 
		EXECUTE GetCurrentID 'id_template_session', @sessionId OUT
        insert into t_acc_template_session(id_session, id_template_owner, nm_acc_type, dt_submission, id_submitter, nm_host, n_status, n_accts, n_subs)
        values (@sessionId, @templateOwner, @p_acc_type, @p_system_time, 0, '', 0, 0, 0)
		execute ApplyAccountTemplate @templateId, @sessionId, @p_system_time, NULL, NULL, 'N', 'N', NULL, NULL, NULL
	END
	ELSE BEGIN
		DECLARE tmpl CURSOR FOR
            SELECT template.id_acc_template, template.id_folder, atype.name
                FROM t_account_ancestor ancestor
                JOIN t_acc_template template ON ancestor.id_descendent = template.id_folder
                JOIN t_account_type atype on template.id_acc_type = atype.id_type
                WHERE ancestor.id_ancestor = @new_parent AND
				    @p_system_time between vt_start AND vt_end
		OPEN tmpl
		FETCH NEXT FROM tmpl INTO @templateId, @templateOwner, @templateType
		WHILE @@FETCH_STATUS = 0 BEGIN
			EXECUTE UpdatePrivateTempates @templateId, @p_system_time 
			EXECUTE GetCurrentID 'id_template_session', @sessionId OUT
			insert into t_acc_template_session(id_session, id_template_owner, nm_acc_type, dt_submission, id_submitter, nm_host, n_status, n_accts, n_subs)
			values (@sessionId, @templateOwner, @p_acc_type, @p_system_time, 0, '', 0, 0, 0)
			execute ApplyAccountTemplate @templateId, @sessionId, @p_system_time, NULL, NULL, 'N', 'N', NULL, NULL, NULL
			FETCH NEXT FROM tmpl INTO @templateId, @templateOwner, @templateType
		END
		CLOSE tmpl
		DEALLOCATE tmpl
	END

	select @status=1
END