
      CREATE FUNCTION [GenerateNextRunTime_Monthly]
	      (
		      @dtNow					DATETIME,
		      @ExecuteTime			CHAR(5),				/*  format "HH:MM" in military */
		      @ExecuteMonthDay		INT			= NULL,		/*  Day of the month when to execute */
		      @ExecuteFirstDayOfMonth	BIT			= NULL,		/*  Execute on the first day of the month */
		      @ExecuteLastDayOfMonth	BIT			= NULL,		/*  Execute on the last day of the month */
		      @SkipTheseMonths		VARCHAR(35)	= NULL		/*  comma seperated set of months that have to be skipped for the monthly schedule executes */
	      )
      RETURNS DATETIME
      AS
	      BEGIN
		      DECLARE 
				@dtNext DATETIME, 
				@bValid BIT, 
				@iPosSkip INT, 
				@iNextPosSkip INT, 
				@tmpSkip INT,
				@tskipnext DATETIME
				
				SELECT @bValid = 0
				
				IF LEN(@SkipTheseMonths)<> 0
				BEGIN
					 IF SUBSTRING(@SkipTheseMonths, LEN(@SkipTheseMonths), 1) <> ','
						  SET @SkipTheseMonths = @SkipTheseMonths + ','
					 
					 SET @iPosSkip = 1
					 SET @iNextPosSkip = CHARINDEX(',', @SkipTheseMonths, @iPosSkip)
					 SET @tskipnext = @dtNow
					  
					  WHILE @iNextPosSkip > 0
					  BEGIN
						  SET @tmpSkip = CAST(SUBSTRING(@SkipTheseMonths, @iPosSkip, (@iNextPosSkip - @iPosSkip)) AS INT)
						  IF MONTH(@tskipnext) = @tmpSkip
							  SET @tskipnext = DATEADD(mm, 1, @tskipnext)
						  IF MONTH(@tskipnext)= MONTH(@dtNow) AND MONTH(DATEADD(mm, 1, @tskipnext))= @tmpSkip AND DAY(@dtNow)>= @ExecuteMonthDay
							  SET @tskipnext = DATEADD(mm, 2, @tskipnext)
						  SET @iPosSkip = @iNextPosSkip + 1
						  SET @iNextPosSkip = CHARINDEX(',', @SkipTheseMonths, @iPosSkip)
					  END
					  
					  IF @tskipnext != @dtNow 
					  BEGIN
						IF ISNULL(@ExecuteFirstDayOfMonth, 0) = 1
						  SET @tskipnext = CAST(MONTH(@tskipnext) AS VARCHAR) + '/01/' + CAST(YEAR(@tskipnext) AS VARCHAR)
						ELSE
							IF ISNULL(@ExecuteLastDayOfMonth, 0) = 1
								SET @tskipnext  = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@tskipnext)+1,0))
							ELSE
								SET @tskipnext = CAST(MONTH(@tskipnext) AS VARCHAR) + '/' + CAST(@ExecuteMonthDay AS VARCHAR) + '/' + CAST(YEAR(@tskipnext) AS VARCHAR)
						SET @tskipnext = dbo.AddTimeToDate(@tskipnext, @ExecuteTime)
						RETURN @tskipnext			
					  END
				END
				
				IF ISNULL(@ExecuteFirstDayOfMonth, 0) = 1
				BEGIN
					SET @dtNext = CAST(MONTH(@dtNow) AS VARCHAR) + '/01/' + CAST(YEAR(@dtNow) AS VARCHAR)
					SET @dtNext = DATEADD(mm, 1, @dtNext)
				END				
				ELSE 
				
					IF ISNULL(@ExecuteLastDayOfMonth, 0) = 1
					BEGIN
						IF DAY(@dtNow)< DAY(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@dtNow)+1,0)))
							SET @dtNext = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@dtNow)+1,0))
						ELSE
							BEGIN
								SET @dtNext = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@dtNow)+1,0))
								SET @dtNext = DATEADD(mm, 1, @dtNext)
							END
					END
					
					ELSE
					BEGIN					
						IF DAY(@dtNow)< @ExecuteMonthDay
							SET @dtNext = CAST(MONTH(@dtNow) AS VARCHAR) + '/' + CAST(@ExecuteMonthDay AS VARCHAR) + '/' + CAST(YEAR(@dtNow) AS VARCHAR)
						ELSE
							BEGIN
								SET @dtNext = CAST(MONTH(@dtNow) AS VARCHAR) + '/' + CAST(@ExecuteMonthDay AS VARCHAR) + '/' + CAST(YEAR(@dtNow) AS VARCHAR)
								SET @dtNext = DATEADD(mm, 1, @dtNext)
							END
					END
				
				SET @dtNext = dbo.AddTimeToDate(@dtNext, @ExecuteTime)
				
				IF DAY(@dtNow)= DAY(@dtNext) AND
				CAST(@dtNow AS TIME)< CAST(@dtNext AS TIME)
				BEGIN
					SET @dtNext = CAST(MONTH(@dtNow) AS VARCHAR) + '/' + CAST(DAY(@dtNext) AS VARCHAR) + '/' + CAST(YEAR(@dtNow) AS VARCHAR)
					SET @dtNext = dbo.AddTimeToDate(@dtNext, @ExecuteTime)
				END
						
			  RETURN @dtNext		
			  END
		