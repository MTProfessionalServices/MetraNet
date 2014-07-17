CREATE OR REPLACE PROCEDURE FILTERSORTQUERY_v3 ( 
             p_InnerQuery          NCLOB, 
             p_OrderByText         VARCHAR2, 
             p_StartRow            NUMBER, 
             p_NumRows             NUMBER, 
             p_TotalRows     OUT   sys_refcursor, 
             p_Rows          OUT   sys_refcursor 
          ) 
          AUTHID CURRENT_USER 
	          AS 
	             v_Sql                 VARCHAR2 (32767) := ''; 
	             v_InnerQueryString    VARCHAR2 (32767) := ''; 
	             v_offset                NUMBER := 1; 
	             v_query_length          NUMBER; 
	             v_buffer                VARCHAR2 (8191) := null; 
	             v_block_length          NUMBER  := 8191; 
	             v_EndRow                NUMBER; 
	             v_OrderByText           VARCHAR2(4096); 
	              
	          BEGIN 
	             v_query_length := dbms_lob.getlength(p_InnerQuery); 
	              
	             IF v_query_length > v_block_length 
	             THEN 
 
	                 while v_offset < v_query_length loop 
	                       dbms_lob.read(p_InnerQuery, v_block_length, v_offset, v_buffer); 
	                       v_InnerQueryString := v_InnerQueryString || v_buffer; 
	                       v_offset := v_offset + v_block_length; 
	                 end loop; 
 
	             ELSE 
 
	                 v_InnerQueryString := v_InnerQueryString || p_InnerQuery; 
 
	             END IF; 
	              
	             IF (p_OrderByText IS NULL) OR (LENGTH(p_OrderByText) = 0)  
	             THEN 
	                 v_OrderByText := 'ORDER BY 1'; /* Must have an ORDER BY for deterministic pagination results */ 
	             ELSE 
	                 v_OrderByText := p_OrderByText; 
	             END IF; 
	              
	             /* Limit counting to the first 1000 rows for performance */ 
             /* Build like a paginated query, but for rows 1 to 1000, */
             /* and then wrap in the COUNT.                           */
             v_EndRow := 1000;
             v_Sql :=
                    'SELECT * FROM ( SELECT /*+ FIRST_ROWS('
                 || v_EndRow
                 || ') */ userquery.*, ROWNUM row_num FROM ('
                 || v_InnerQueryString
                 || ' '
                 || v_OrderByText
                 || ' ) userquery WHERE ROWNUM <= ' /* Must use the PSEUDOCOLUMN name here for STOPKEY optimization */
                 || v_EndRow
                 || ') abc WHERE row_num >= 1'      /* Must use the renamed PSEUDOCOLUMN here for > or >= operations */
                 ;
                 
             v_Sql := 'SELECT /*+ FIRST_ROWS(' || v_EndRow || ') */ COUNT(1) TotalRows FROM (' || CHR(10) ||
                      v_Sql                                                                    || CHR(10) ||
					            ') WHERE ROWNUM <= ' || v_EndRow;   /* Must use the PSEUDOCOLUMN name here */
 
	               
	             OPEN p_TotalRows FOR v_Sql;  
	 
	             IF p_NumRows > 0 
	             THEN 
	               v_EndRow := p_StartRow + p_NumRows - 1; 
	 
	               v_Sql := 
	                      'SELECT * FROM ( SELECT /*+ FIRST_ROWS(' 
	                   || v_EndRow 
	                   || ') */ userquery.*, ROWNUM row_num FROM (' 
	                   || v_InnerQueryString 
	                   || ' ' 
	                   || v_OrderByText 
	                   || ' ) userquery WHERE ROWNUM <= ' /* Must use the PSEUDOCOLUMN name here for STOPKEY optimization */ 
	                   || v_EndRow 
	                   || ') abc WHERE row_num >= '       /* Must use the renamed PSEUDOCOLUMN here for > or >= operations */ 
	                   || p_StartRow; 
	               ELSE 
                  v_EndRow := 1000; /* Limit when selecting data for all rows */
	                v_Sql := 
	                      'SELECT * FROM ( SELECT userquery.*, ROWNUM row_num FROM (' 
	                   || v_InnerQueryString 
	                   || ' ' 
	                   || v_OrderByText 
	                   || ' ) userquery WHERE ROWNUM <= '
                     || v_EndRow
                     || ') abc';
	             END IF; 
	 
	             OPEN p_Rows FOR v_Sql; 
	          END; 
	       
