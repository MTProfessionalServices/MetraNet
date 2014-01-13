
              create FUNCTION MTStartOfDay (@indate datetime) returns datetime
              as
              begin
                -- This commented line of code also works.  I have commented
                -- it out until we get a chance to test it and see which of
                -- these two ways is fastest.
                --
                -- return CAST(ROUND(CAST(@indate AS FLOAT), 0, 1) AS DATETIME)
                declare @retval as datetime
                select @retval =  DATEADD(hh,-DATEPART(hh, @indate),
                                  DATEADD(mi,-DATEPART(mi, @indate),
                                  DATEADD(s,-DATEPART (s, @indate),
                                  DATEADD(ms,-DATEPART(ms, @indate), @indate))))
                return @retval
              end
      