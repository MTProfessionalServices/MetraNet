
      /*
      	Proc: GeneratePartitionSequence
      
      	Returns a list partitions based on current partition type
      	and active intervals.
      
      */
      create proc GeneratePartitionSequence
      	@partitions cursor varying output
      AS
      begin
      
      /* Get the partition cycle from t_usage_server
       * e.g. weekly, bi-monthly, monthly, yearly
      */
      declare @cycle int
      select @cycle = partition_cycle from t_usage_server
      -- Only 4 cycles supported 33, 34, 383, 520 (see check for supported cycle ids in __SET_PARTITION_OPTIONS_SP__ under comment -- find cycle id for a supported partition cycle
      -- todo: Check that @cycle is in (33, 34, 383, 520)
      --			1 row expected
      --			exception handling
      
		-- Determine if this is a conversion and include 
		--	hard-closed intervals if so.
		declare @intervalstatus varchar(10)
		set @intervalstatus = '[BO]'
		if objectproperty(object_id('t_acc_usage'),'istable') = 1
			set @intervalstatus = '[HBO]'

      /* Get high and low end-dates for all active intervals
      */
      declare @dtmin datetime, @dtmax datetime
      select @dtmin = min(dt_end), @dtmax = max(dt_end)
      from t_usage_interval ui
      where ui.tx_interval_status like @intervalstatus
      
      /* Get end-date of eldest active partition.  If there aren't
      	any partitions yet then use lowest of active interval end-dates.
      */
      declare @dtend datetime  -- new partition starts on day after last
      select @dtend = max(dt_end) from t_partition
      where b_active = 'Y'
      --	todo: exception handling
      
      /* The start of the new partition range is always the day
      	after the last partition ends.  If there is no prior
      	partition, then use the youngest of the interval end-dates.
      */
      declare @start datetime
      select @start = isnull(@dtend + 1, @dtmin)
      
      /*-- debugging...
      -- convert(varchar, @now, 102) the hack string
      declare @dtend datetime
      set @cycle = 30
      set @dtend = null 
      set @dtend = '2005-01-15 23:59:59'
      set @dtmin = '2005-05-31 23:59:59' 
      set @dtmax = '2005-09-05 23:59:59'
      */
      
      /* Round start dates down to whole day
      */
      set @dtmin = convert(varchar, @dtmin, 102)
      set @start = convert(varchar, @start, 102)
      
      /* debugging
      select @cycle as cyc, @dtend as dtend, @start as start, 
      	@dtmin as dtmin, @dtmax as dtmax
      */
      
      /* Get the partition sequence
      */
      declare partscur cursor local for
      select 
      		-- The real start of the cycle; untruncated
      		--dt_start as interval_start, 
      
      		-- dt_start might be the truncated start of the interval
      		case
      			when @dtend is not null and @start > dt_start 
      			then @start else dt_start end
      		as dt_start,
      
      		-- dt_end is the end of the interval
      		dt_end,
      
      		-- interval_start is a usage-interval key equivalent
      		-- used to constrain the partition's lower bound.
      		datediff(d, '1970-1-1', case
      					when @dtend is not null and @start > dt_start
      					then @start else dt_start end
      					)
      				* power(2,16) 
      			as interval_start,
      
      		-- interval_end is a usage-interval key equivalent
      		-- used to constrain the partition's upper bound
      		datediff(d, '1970-1-1', dt_end) * power(2,16)  
      				+ (power(2,16) - 1) 
      			as interval_end
      
      from t_pc_interval 
      where id_cycle = @cycle
      and dt_end > @start		
      and dt_start <= @dtmax
      order by dt_end
      
      /* Open the cursor for the caller.
      */
      open partscur
      set @partitions = partscur
      
      end -- procedure
 	