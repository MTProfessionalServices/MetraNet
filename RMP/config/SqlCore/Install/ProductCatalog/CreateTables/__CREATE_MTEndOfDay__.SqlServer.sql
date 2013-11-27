
				create function MTEndOfDay(@indate as datetime) returns datetime
				as
				begin
					declare @retval as datetime
					/* ESR-3933 any year <= 2037 then return the end of the day for @indate */
					if (DATEPART(yyyy, @indate) <= 2037)
						set @retval =
							DATEADD(s,-1,
								DATEADD(d,1,	
									DATEADD(hh,-DATEPART(hh,@indate),
										DATEADD(mi,-DATEPART(mi,@indate),
											DATEADD(s,-DATEPART (s,@indate),
												DATEADD(ms,-DATEPART (ms,@indate),@indate)
											)
										)
									)
								)
							)
					/* ESR-3933 when year > 2037 return 2038-01-01 00:00:00.000 */					
					ELSE
						set @retval = dbo.MTMaxDate()
					return @retval
				end
	