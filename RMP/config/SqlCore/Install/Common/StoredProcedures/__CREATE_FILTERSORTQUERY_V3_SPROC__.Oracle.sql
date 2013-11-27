
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
             
             v_Sql := 'SELECT COUNT(1) TotalRows FROM (' || v_InnerQueryString || ')';
              
             OPEN p_TotalRows FOR v_Sql; /*v_Sql := 'SELECT * FROM ( SELECT userquery.*, ROWNUM row_num FROM (' || p_InnerQuery || ' ' || p_OrderByText || ' ) userquery ) abc WHERE row_num >= ' || p_StartRow || ' AND row_num <= ' || (p_StartRow + p_NumRows);*/

             IF p_NumRows > 0
             THEN
                v_Sql :=
                      'SELECT * FROM ( SELECT userquery.*, ROWNUM row_num FROM ('
                   || v_InnerQueryString
                   || ' '
                   || p_OrderByText
                   || ' ) userquery ) abc WHERE row_num >= '
                   || p_StartRow
                   || ' AND row_num < '
                   || (p_StartRow + p_NumRows);
             ELSE
                v_Sql :=
                      'SELECT * FROM ( SELECT userquery.*, ROWNUM row_num FROM ('
                   || v_InnerQueryString
                   || ' '
                   || p_OrderByText
                   || ' ) userquery  ) abc';
             END IF;

             OPEN p_Rows FOR v_Sql;
          END;
      