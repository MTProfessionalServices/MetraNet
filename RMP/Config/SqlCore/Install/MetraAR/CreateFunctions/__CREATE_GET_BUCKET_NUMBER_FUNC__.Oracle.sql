
              CREATE OR REPLACE function GetBucketNumber (p_currentDate DATE, p_agingDate DATE, p_agingAlgorithm int) return int as 
v_bucketNumber int;
                v_monthDiff int;
                v_dayDiff int;
                begin

                /* get the month difference */
                SELECT MONTHS_BETWEEN(p_currentDate, p_agingDate) into v_monthDiff FROM dual; 

                /* get the day difference */
                SELECT ROUND(p_currentDate - p_agingDate) into v_dayDiff FROM dual;

                /* subtract 1 from the month diff b/c the invoice has not rolled over to the next bucket according to its due date 
                even though the month difference is greater
                if the day diff is 0, then decrement the month diff b/c we don't want it to rollover until the folowing day
                */

                If v_dayDiff <= 0 Then
                 v_monthDiff := v_monthDiff - 1;                
                End If;

                If (p_currentDate < p_agingDate) Then
                    v_bucketNumber := -1;
                ElsIf v_monthDiff <= 0 Then
                    v_bucketNumber := 0;
                ElsIf v_monthDiff = 1 Then
                    v_bucketNumber := 1;
                ElsIf v_monthDiff = 2 Then
                    v_bucketNumber := 2;
                ElsIf v_monthDiff = 3 Then
                    v_bucketNumber := 3;
                ElsIf v_monthDiff = 4 Then
                    v_bucketNumber := 4;
                ElsIf v_monthDiff > 4 Then
                    v_bucketNumber := 5;
                End If;
                return v_bucketNumber;              
              End;
				