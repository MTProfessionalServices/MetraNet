
				DECLARE
					l_TotalRows number(10,0);
				BEGIN
					SELECT COUNT(1) TotalRows into l_TotalRows FROM (%%QUERY_To_RETURN_COUNT%%) %%TOP_ROWS%%;
					
					Open :TotalRows for
						Select l_TotalRows from Dual;

					Open :Rows for
					SELECT * FROM ( SELECT userquery.*, ROWNUM row_num FROM 
					(%%INNER_QUERY%% %%ORDER_BY_TEXT%%) userquery ) abc 
					WHERE row_num >= :StartRow AND row_num <= nvl(:EndRow, l_TotalRows);
	          END;
      