
create proc BulkSubscriptionChange(
@id_old_po as int,
@id_new_po as int,
@date as datetime,
@nextbillingcycle as varchar(1),
@p_systemdate datetime,
@new_sub int,
@p_status int output
)
as
DECLARE @CursorVar CURSOR	
DECLARE @count as int
declare @i as int
declare @id_acc as int
declare @start_date as datetime
declare @end_date as datetime
declare @id_sub as int
declare @varmaxdatetime datetime
declare @subext as varbinary(16)
declare @realenddate as datetime
declare @datemodified as varchar(1)
declare @tmp bigint
SET @p_status = 1
-- lock everything down as tight as possible!
--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
begin 
select @varmaxdatetime = dbo.mtmaxdate ()
-- should we update the end effective date of the 
-- old product offering here?
-- create a cursor that holds a static list of all old
-- subscriptions that have end dates later than the old date
set @CursorVar = CURSOR STATIC FOR
	select id_acc,vt_start,vt_end,id_sub
	from t_sub
	where t_sub.id_po = @id_old_po AND
	t_sub.vt_end >= @date
	AND id_group is NULL
OPEN @CursorVar
set @count = @@cursor_rows
set @i = 0
while @i < @count begin
	FETCH NEXT FROM @CursorVar into @id_acc,@start_date,@end_date,@id_sub
	set @i = (select @i + 1)
	select @subext = CAST(newid() as varbinary(16))


	select @realenddate = case when @nextbillingcycle = 'Y' AND @date is not null then
		dbo.subtractsecond(dbo.NextDateAfterBillingCycle(@id_acc,@date))
	else
		dbo.subtractsecond(@date)
	end		

        -- it is possible that @date <= @end_date <= @realenddate
        -- for this case treat as though subscription doesn't match at all
        if @end_date <= @realenddate 
          continue

        -- either delete or update the old subscription
        if @realenddate >= @start_date
        begin
	  -- update the old subscription use the specified date
	  update t_sub set vt_end = @realenddate where
	  id_sub = @id_sub

	  -- update the old subscription tt_end
	 UPDATE t_sub_history
           SET tt_end = dbo.subtractsecond (@p_systemdate)
	 WHERE id_sub = @id_sub
	 and tt_end = @varmaxdatetime

	 -- insert the new record
	 INSERT INTO t_sub_history
         SELECT id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group,
         vt_start, @realenddate, @p_systemdate, @varmaxdatetime
         FROM t_sub_history
         WHERE id_sub = @id_sub
         AND tt_end = dbo.subtractsecond (@p_systemdate)
        end
        else
        begin
	  -- update the old subscription use the specified date
	  delete from t_sub where id_sub = @id_sub
	  -- update the old subscription tt_end
	 UPDATE t_sub_history
           SET tt_end = dbo.subtractsecond (@p_systemdate)
	 WHERE id_sub = @id_sub
	 and tt_end = @varmaxdatetime
        end

	-- Apply the mashing function to the unmixed id
	set @tmp = @new_sub
        set @tmp = @tmp + (@tmp * 4096);
        set @tmp = @tmp & 0x7fffffff;

        set @tmp = @tmp ^ (@tmp / 4194304);

        set @tmp = @tmp + (@tmp * 16);
        set @tmp = @tmp & 0x7fffffff;

        set @tmp = @tmp ^ (@tmp / 512);

        set @tmp = @tmp + (@tmp * 1024);
        set @tmp = @tmp & 0x7fffffff;

        set @tmp = @tmp ^ (@tmp / 4);

        set @tmp = @tmp + (@tmp * 128);
        set @tmp = @tmp & 0x7fffffff;

        set @tmp = @tmp ^ (@tmp / 4096);

	exec AddNewSub  
		@id_acc,
		@date,
		@end_date,
		@nextbillingcycle, -- next billing cycle after start date
		'N',
		@id_new_po,
		@subext,
		@p_systemdate,
		@tmp,
		@p_status OUTPUT,
		@datemodified OUTPUT

	-- if @new_status is not 0 then raise an error
	-- CR 11160: set output result parameter and return error
	if @p_status <> 1 
	begin
		CLOSE @CursorVar
		DEALLOCATE @CursorVar	
		return
	end
	/* CR 12529 - increment the id */
	set @new_sub = @new_sub + 1
end 
CLOSE @CursorVar
DEALLOCATE @CursorVar
end
		