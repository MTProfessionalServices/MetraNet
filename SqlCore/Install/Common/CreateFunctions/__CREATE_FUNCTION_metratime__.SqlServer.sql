CREATE FUNCTION [metratime](@utc int = 0, @app_name varchar(256) = null) RETURNS DATETIME
AS
BEGIN
                DECLARE @result_date DATETIME;
                DECLARE @now DATETIME;
                DECLARE @add_seconds INT;
  IF (@utc IS NULL OR @utc = 0)
  BEGIN
       set @now = GETDATE();
  END
  ELSE
  BEGIN
       set @now = GETUTCDATE();
  END;
                SELECT TOP 1 @result_date = frozen_date,
                       @add_seconds = add_seconds
                FROM   t_metratime
  WHERE IsNull(application_name,'Default') = IsNull(@app_name, 'Default');
                -- If no rows, return getdate(). This is default behavior for production systems
                IF (@result_date IS NULL AND @add_seconds IS NULL)
                    RETURN @now;
                -- If the frozen date was not set, start with getdate()
                IF (@result_date IS NULL)
                                set @result_date = @now;
                -- If add seconds was specified add them now
                IF (@add_seconds IS NOT NULL)
                                set @result_date =DATEADD(ss, @add_seconds, @result_date);
                RETURN @result_date;
END
;
