
CREATE FUNCTION DeriveEBCRCycle 
(
  @usageCycle INT,     -- billing cycle of the account (context-sensitive)
  @subStart DATETIME,  -- start date of the subscription/membership (context-sensitive)
  @ebcrCycleType INT   -- cycle type of the EBCR PI 
) 
RETURNS INT
AS
BEGIN
  DECLARE @usageCycleType INT
  DECLARE @derivedEBCRCycle INT

  DECLARE @startDay INT
  DECLARE @startMonth INT
  DECLARE @endDay INT

  DECLARE @tempDate DATETIME
  DECLARE @endOfMonth INT

	  -- looks up the usage cycle's cycle type
  SELECT @usageCycleType = id_cycle_type
  FROM t_usage_cycle
  WHERE id_usage_cycle = @usageCycle

  IF (@@ROWCOUNT != 1)
    RETURN -1 -- ERROR: Exactly one usage cycle type was not found for given usage cycle ID
   
  -- if  cycle types are identical then EBCR reduces to a trivial BCR case
  IF (@ebcrCycleType = @usageCycleType)
    RETURN @usageCycle      

  -- Case map:
  --   -Weekly EBCR
  --      -Bi-weekly BC
  --   - Bi-weekly EBCR
  --      -Weekly BC
  --   -Monthly EBCR
  --      -Quarterly BC
  --      -Annual BC
  --   -Quarterly EBCR
  --      -Monthly BC
  --      -Annual BC
  --   -Annual EBCR
  --      -Monthly BC
  --      -Quarterly BC

  -- Weekly EBCR
  IF (@ebcrCycleType = 4)
  BEGIN
    -- only Bi-weekly cycle type is permitted
    IF (@usageCycleType != 5)
      RETURN -3 -- ERROR: unsupported EBCR cycle combination

    -- retrieves the Bi-weekly start day
    SELECT @startDay = start_day
    FROM t_usage_cycle uc
    WHERE uc.id_usage_cycle = @usageCycle

    -- reduces the start day [1,14] to a start day between [1,7]
    SET @startDay = @startDay % 7
    IF (@startDay = 0)
      SET @startDay = 7

    --   January 2000    
    -- Su Mo Tu We Th Fr Sa
    --                    1
    --  2  3  4  5  6  7  8
    --  9 10 11 12 13 14 15
    -- 16 17 18 19 20 21 22
    -- 23 24 25 26 27 28 29
    -- 30 31 
  
    -- Bi-weekly      Weekly
    -- start day  --> end day of week
    -- 1, 8              6
    -- 2, 9              7
    -- 3, 10             1
    -- 4, 11             2
    -- 5, 12             3
    -- 6, 13             4
    -- 7, 14             5
 
    -- translates the start day to an end day of week for use with Weekly 
    SET @endDay = @startDay - 2
    IF (@endDay < 1)  -- handles wrap around
      SET @endDay = @endDay + 7
      
    SELECT @derivedEBCRCycle = ebcr.id_usage_cycle
    FROM t_usage_cycle ebcr
    WHERE 
      ebcr.id_cycle_type = @ebcrCycleType AND 
      ebcr.day_of_week = @endDay
  END
   -- Bi-weekly EBCR
   ELSE IF (@ebcrCycleType = 5)
   BEGIN
      -- only a Weekly cycle type is permitted
      IF (@usageCycleType != 4)
         RETURN -3 -- ERROR: unsupported EBCR cycle combination

      -- retrieves the Weekly end day
      SELECT @endDay = day_of_week
      FROM t_usage_cycle uc
      WHERE uc.id_usage_cycle = @usageCycle

      -- performs the reverse translation described in the Weekly EBCR case
      -- NOTE: subscription information is ignored
      SET @startDay = @endDay + 2 
      IF (@startDay > 7)  -- handles wrap around
        SET @startDay = @startDay - 7
         
      SELECT @derivedEBCRCycle = ebcr.id_usage_cycle
      FROM t_usage_cycle ebcr
      WHERE 
         ebcr.id_cycle_type = @ebcrCycleType AND 
         ebcr.start_day = @startDay AND
         ebcr.start_month = 1 AND
         ebcr.start_year = 2000
   END

   -- Monthly EBCR
   ELSE IF (@ebcrCycleType = 1)
   BEGIN
      -- only Quarterly, Semi-annual, and Annual billing cycle types are legal for this case
      IF (@usageCycleType NOT IN (7, 8, 9))
         RETURN -3 -- ERROR: unsupported EBCR cycle combination

      -- the usage cycle type is Quarterly, semi-annual, or Annual
      -- which use the same start_day property
      SELECT @startDay = start_day
      FROM t_usage_cycle uc
      WHERE uc.id_usage_cycle = @usageCycle

      -- translates the start day to an end day since Monthly cycle types
      -- use end days and Quarterly and Annual cycle types use start days
      BEGIN
        SET @endDay = @startDay - 1
        IF (@endDay < 1) -- wraps around to EOM
           SET @endDay = 31
      END

      
      SELECT @derivedEBCRCycle = ebcr.id_usage_cycle
      FROM t_usage_cycle ebcr
      WHERE 
         ebcr.id_cycle_type = @ebcrCycleType AND 
         ebcr.day_of_month = @endDay
   END

   -- Quarterly EBCR
   ELSE IF (@ebcrCycleType = 7)
   BEGIN
      -- Monthly billing cycle type
      IF (@usageCycleType = 1)
      BEGIN
         -- infers the start month from the subscription start date   
         /* CORE-8006 */ 
        SELECT 
			@startDay = DATEPART(day, tui.dt_start),
			@startMonth = DATEPART(month, tui.dt_start)
		 FROM t_usage_interval tui
         JOIN t_usage_cycle tuc on tuc.id_usage_cycle = tui.id_usage_cycle
         WHERE tui.id_usage_cycle = @usageCycle
              AND tui.dt_start <= @subStart
              AND tui.dt_end > @subStart

		 --Leap years are a problem.  If the last day of the month is the 29th, it's really the 28th for this purpose
		 if (@startMonth = 2 AND @startDay = 29)
			SET @startDay = 28
  
         -- reduces start month to a value between 1 and 3 since there are
         -- really only 3 months of quarterly cycles:
         -- Original Month: Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
         --                   1   2   3   4   5   6   7   8   9  10  11  12
         -- Reduced Month:    1   2   3   1   2   3   1   2   3   1   2   3
         SET @startMonth = @startMonth % 3
         IF (@startMonth = 0)
            SET @startMonth = 3 
      END
      -- Annual or semiannual billing cycle type
      ELSE IF (@usageCycleType IN (8, 9))
      BEGIN
         SELECT 
            @startDay = start_day,
            @startMonth = start_month
         FROM t_usage_cycle uc
         WHERE uc.id_usage_cycle = @usageCycle
      END
      ELSE
         RETURN -3 -- ERROR: unsupported EBCR cycle combination

      -- translates the Annual start month [1 - 12] to a Quarterly start month [1 - 3]
      SET @startMonth = @startMonth % 3
      IF (@startMonth = 0)
        SET @startMonth = 3
 
      SELECT @derivedEBCRCycle = ebcr.id_usage_cycle
      FROM t_usage_cycle ebcr
      WHERE 
         ebcr.id_cycle_type = @ebcrCycleType AND 
         ebcr.start_day = @startDay AND
         ebcr.start_month = @startMonth
   END
   
   -- Annual EBCR
   ELSE IF (@ebcrCycleType = 8)
   BEGIN
      -- Monthly billing cycle type
      IF (@usageCycleType = 1)
      BEGIN
        -- infers the start month from the subscription start date   
         /* CORE-8006 */ 
         SELECT 
			@startDay = DATEPART(day, tui.dt_start),
			@startMonth = DATEPART(month, tui.dt_start)
		 FROM t_usage_interval tui
         JOIN t_usage_cycle tuc on tuc.id_usage_cycle = tui.id_usage_cycle
         WHERE tui.id_usage_cycle = @usageCycle
              AND tui.dt_start <= @subStart
              AND tui.dt_end > @subStart

		 --Leap years are a problem.  If the last day of the month is the 29th, it's really the 28th for this purpose
		 if (@startMonth = 2 AND @startDay = 29)
			SET @startDay = 28

      END
      -- Quarterly billing cycle type (treat semiannual the same)
      ELSE IF (@usageCycleType IN (7, 9))
      BEGIN
         SELECT 
            @startDay = start_day,
            @startMonth = start_month  
         FROM t_usage_cycle uc
         WHERE uc.id_usage_cycle = @usageCycle

		 --Fix for cases where quarterly billing would map to 2/29-31
         SET @tempDate = dateadd(mm, 101 * 12 + @startMonth - 1 , @startDay - 1)
	     SET @endOfMonth = DATEPART(day, DATEADD(dd, -DAY(DATEADD(m,1,@tempDate)), DATEADD(m,1,@tempDate)))
	     
		 IF @startDay > @endOfMonth
	        SET @startDay = @endOfMonth
      END      
      
      SELECT @derivedEBCRCycle = ebcr.id_usage_cycle
      FROM t_usage_cycle ebcr
      WHERE 
         ebcr.id_cycle_type = @ebcrCycleType AND 
         ebcr.start_day = @startDay AND
         ebcr.start_month = @startMonth
    END
    -- SemiAnnual EBCR
   ELSE IF (@ebcrCycleType = 9)
   BEGIN
      -- Monthly billing cycle type
      IF (@usageCycleType = 1)
      BEGIN
        -- infers the start month from the subscription start date   
          /* CORE-8006 */ 
         SELECT 
			@startDay = DATEPART(day, tui.dt_start),
			@startMonth = DATEPART(month, tui.dt_start)
		 FROM t_usage_interval tui
         JOIN t_usage_cycle tuc on tuc.id_usage_cycle = tui.id_usage_cycle
         WHERE tui.id_usage_cycle = @usageCycle
              AND tui.dt_start <= @subStart
              AND tui.dt_end > @subStart
		
		 --Leap years are a problem.  If the last day of the month is the 29th, it's really the 28th for this purpose
		 if (@startMonth = 2 AND @startDay = 29)
			SET @startDay = 28
        
      END
      -- Quarterly or annual billing cycle type 
      ELSE IF (@usageCycleType in (7,8))
      BEGIN
         SELECT 
            @startDay = start_day,
            @startMonth = start_month  
         FROM t_usage_cycle uc
         WHERE uc.id_usage_cycle = @usageCycle

		 --Fix for cases where quarterly billing would map to 2/29-31
         SET @tempDate = dateadd(mm, 101 * 12 + @startMonth - 1 , @startDay - 1)
	     SET @endOfMonth = DATEPART(day, DATEADD(dd, -DAY(DATEADD(m,1,@tempDate)), DATEADD(m,1,@tempDate)))
	     if @startDay > @endOfMonth
	        SET @startDay = @endOfMonth
      END
      ELSE
         RETURN -3 -- ERROR: unsupported usage cycle combination
      
      SELECT @derivedEBCRCycle = ebcr.id_usage_cycle
      FROM t_usage_cycle ebcr
      WHERE 
         ebcr.id_cycle_type = @ebcrCycleType AND 
         ebcr.start_day = @startDay AND
         ebcr.start_month = @startMonth
  END
  ELSE
    RETURN -4 -- unsupported EBCR cycle type

  IF (@derivedEBCRCycle IS NULL)
    RETURN -5   -- derivation failed

  RETURN @derivedEBCRCycle
END