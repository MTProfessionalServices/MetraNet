
			Declare @TotalRows int
			SELECT @TotalRows = COUNT(1) FROM (SELECT %%TOP_ROWS%% * FROM (%%INNER_QUERY%%) CAPPED) CNTQ;
			SELECT @TotalRows;
		 
			WITH Q AS (SELECT *, ROW_NUMBER() OVER (%%ORDER_BY_TEXT%%) as RowNumber
			FROM (%%INNER_QUERY%%) IQ )  
			SELECT * FROM Q WHERE RowNumber BETWEEN @StartRow AND COALESCE(@EndRow, @TotalRows)	   
      