
create Procedure %%PROCNAME%% (
%%PARAMS%%
@startdate  datetime,
@enddate datetime,
@p_systemdate datetime,
@status int OUTPUT
)
as
declare @realstartdate datetime
declare @realenddate datetime
declare @varMaxDateTime datetime
declare @tempStartDate datetime
declare @tempEndDate datetime
declare @onesecond_systemdate datetime
%%TEMP_VARIABLES%%
begin

-- detect directly adjacent records with a adjacent start and end date.  If the
-- key comparison matches successfully, use the start and/or end date of the original record 
-- instead.

select @realstartdate = @startdate,@realenddate = @enddate,@varMaxDateTime = dbo.mtmaxdate(),
  @onesecond_systemdate = dbo.subtractsecond(@p_systemdate)

 -- Someone changes the start date of an existing record so that it creates gaps in time
 -- Existing Record      |---------------------|
 -- modified record       	|-----------|
 -- modified record      |-----------------|
 -- modified record         |------------------|
	begin
		
		-- find the start and end dates of the original interval
		select 
		@tempstartdate = vt_start,
		@tempenddate = vt_end
    from
    %%HISTORYTABLE%% with(updlock)
    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    %%COMPARISIONSTR%% and tt_end = @varMaxDateTime 

		-- the original date range is no longer true
		update %%HISTORYTABLE%%
    set tt_end = @onesecond_systemdate
		where %%COMPARISIONSTR%% AND vt_start = @tempstartdate AND
		@tempenddate = vt_end AND tt_end = @varMaxDateTime

		-- adjust the two records end dates that are adjacent on the start and
		-- end dates; these records are no longer true
		update %%HISTORYTABLE%% 
		set tt_end = @onesecond_systemdate where
		%%KEY_COMPARISION%% AND tt_end = @varMaxDateTime AND
		(vt_end = dbo.subtractSecond(@tempstartdate) OR vt_start = dbo.addsecond(@tempenddate))
    if (@@error <> 0 )
		begin
    select @status = 0
		end

		insert into %%HISTORYTABLE%% 
		(%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
		select 
			%%COMMA_PARAMS%%,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
			from %%HISTORYTABLE%% 
			where
			%%KEY_COMPARISION%% AND vt_end = dbo.subtractSecond(@tempstartdate)
		UNION ALL
		select
			%%COMMA_PARAMS%%,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
			from %%HISTORYTABLE%%
			where
			%%KEY_COMPARISION%%  AND vt_start = dbo.addsecond(@tempenddate)

	end

	-- detect directly adjacent records with a adjacent start and end date.  If the
	-- key comparison matches successfully, use the start and/or end date of the original record 
	-- instead.
    if %%SUBSCRIPTION%% begin
        select @realstartdate = @startdate
        select @realenddate = @enddate;
    end 
    else begin
	    select @realstartdate = vt_start
	    from 
	    %%HISTORYTABLE%%  where %%COMPARISIONSTR%% AND
		    @startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime
	    if @realstartdate is NULL begin
		    select @realstartdate = @startdate
	    end;
	    --CR 10620 fix: Do not add a second to end date
	    select @realenddate = vt_end
	    from
	    %%HISTORYTABLE%%  where %%COMPARISIONSTR%% AND
	    @enddate between vt_start AND vt_end and tt_end = @varMaxDateTime
	    if @realenddate is NULL begin
		    select @realenddate = @enddate
	    end;
    end 
        
 -- step : delete a range that is entirely in the new date range
 -- existing record:      |----|
 -- new record:      |----------------|
 update  %%HISTORYTABLE%% 
 set tt_end = @onesecond_systemdate
 where dbo.EnclosedDateRange(@realstartdate,@realenddate,vt_start,vt_end) =1 AND
 %%KEY_COMPARISION%%  AND tt_end = @varMaxDateTime 

 -- create two new records that are on around the new interval        
 -- existing record:          |-----------------------------------|
 -- new record                        |-------|
 --
 -- adjusted old records      |-------|       |--------------------|
  begin
    select
		%%COMMA_TEMPVARS_ASSIGNMENT_SQLSERVER%%	
		,@tempstartdate = vt_start,
		@tempenddate = vt_end
    from
    %%HISTORYTABLE%%
    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    %%KEY_COMPARISION%% and tt_end = @varMaxDateTime %%NON_KEY_COMPARISION%%
    update     %%HISTORYTABLE%% 
    set tt_end = @onesecond_systemdate where
    dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    %%KEY_COMPARISION%% AND tt_end = @varMaxDateTime %%NON_KEY_COMPARISION%%
   
-- CR 14491 - Primary keys can not be null
if %%PRIMARY_KEYS_NOT_NULL%%
begin

insert into %%HISTORYTABLE%% 
   (%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
   select 
    %%COMMA_TEMPVARS%%,@tempStartDate,dbo.subtractsecond(@realstartdate),
    @p_systemdate,@varMaxDateTime
    where @tempstartdate is not NULL AND @tempStartDate <> @realstartdate
    -- the previous statement may fail
		if @realenddate <> @tempendDate AND @realenddate <> @varMaxDateTime begin
			insert into %%HISTORYTABLE%% 
			(%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
	    select
	    %%COMMA_TEMPVARS%%,@realenddate,@tempEndDate,
	    @p_systemdate,@varMaxDateTime
		end
      
end

  -- the previous statement may fail
  end
 -- step 5: update existing payment records that are overlapping on the start
 -- range
 -- Existing Record |--------------|
 -- New Record: |---------|
 insert into %%HISTORYTABLE%%
 (%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
 select 
 %%COMMA_PARAMS%%,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
 from 
 %%HISTORYTABLE%%  where
 %%KEY_COMPARISION%% AND 
 vt_start > @realstartdate and vt_start < @realenddate 
 and tt_end = @varMaxDateTime
 
 if %%SUBSCRIPTION%% begin
     update %%HISTORYTABLE%%
    set tt_end = @onesecond_systemdate
    where
    %%KEY_COMPARISION%%     and tt_end = @varMaxDateTime;
  end else begin
    update %%HISTORYTABLE%%
    set tt_end = @onesecond_systemdate
    where
    %%KEY_COMPARISION%% AND 
    vt_start > @realstartdate and vt_start < @realenddate 
    and tt_end = @varMaxDateTime
 end
  
 -- step 4: update existing payment records that are overlapping on the end
 -- range
 -- Existing Record |--------------|
 -- New Record:             |-----------|
 insert into %%HISTORYTABLE%%
 (%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
 select
 %%COMMA_PARAMS%%,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
 from %%HISTORYTABLE%%
 where
 %%KEY_COMPARISION%% AND 
 vt_end > @realstartdate AND vt_end < @realenddate
 AND tt_end = @varMaxDateTime
 
  if %%SUBSCRIPTION%% begin
     update %%HISTORYTABLE%%
     set tt_end = @onesecond_systemdate
     where %%KEY_COMPARISION%%
     AND tt_end = @varMaxDateTime;
   end else begin
        update %%HISTORYTABLE%%
    set tt_end = @onesecond_systemdate
    where
    %%KEY_COMPARISION%%  AND 
      vt_end > @realstartdate AND vt_end < @realenddate 
      and tt_end = @varMaxDateTime
  end

 -- used to be realenddate
 -- step 7: create the new payment redirection record.  If the end date 
 -- is not max date, make sure the enddate is subtracted by one second
 insert into %%HISTORYTABLE%% 
 (%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
 select 
 %%COMMA_INPUT_PARAMS%%,@realstartdate,
  case when @realenddate = dbo.mtmaxdate() then @realenddate else 
  %%ENDDATE_PARAM%% end,
  @p_systemdate,@varMaxDateTime
  
delete from %%TABLENAME%% where %%KEY_COMPARISION%%
insert into %%TABLENAME%% (%%COMMA_PARAMS%%,vt_start,vt_end)
select %%COMMA_PARAMS%%,vt_start,vt_end
from %%HISTORYTABLE%%  where
%%KEY_COMPARISION%% and tt_end = @varMaxDateTime
 select @status = 1
 end
			