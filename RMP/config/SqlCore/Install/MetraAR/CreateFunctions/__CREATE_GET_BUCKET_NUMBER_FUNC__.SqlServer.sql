
              create function [GetBucketNumber] (@currentDate datetime, @agingDate datetime, @agingAlgorithm int) returns int
              as
                begin
                declare @bucketNumber as int      
                declare @monthDiff int
                declare @dayDiff int

                /* get the month difference */
                set @monthDiff = DateDiff(m, @agingDate, @currentDate)

                /* get the day difference */
                set @dayDiff = DatePart(d, @currentDate) - DatePart(d, @agingDate)

                /* subtract 1 from the month diff b/c the invoice has not rolled over to the next bucket according to its due date 
                even though the month difference is greater
                if the day diff is 0, then decrement the month diff b/c we don't want it to rollover until the folowing day
                */

                If @dayDiff <= 0 
                set @monthDiff = @monthDiff - 1

                If @currentDate < @agingDate 
                    set @bucketNumber = -1
                Else If @monthDiff <= 0 
                    set @bucketNumber = 0
                Else If @monthDiff = 1
                    set @bucketNumber = 1
                Else If @monthDiff = 2
                    set @bucketNumber = 2
                Else If @monthDiff = 3
                    set @bucketNumber = 3
                Else If @monthDiff = 4
                    set @bucketNumber = 4
                Else If @monthDiff > 4
                    set @bucketNumber = 5
                    
                return @bucketNumber              
              End
				