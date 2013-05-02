
CREATE GLOBAL TEMPORARY TABLE tmp_nrc_gsubmember 
( 
          ID_PO            NUMBER(10),
          ID_ACC           NUMBER(10),
          ID_SUB           NUMBER(10),
          VT_START         DATE,
          VT_END           DATE,
          TT_START         DATE,
          TT_END           DATE,
          MAX_VT_TT_START  DATE,
          MAX_VT_TT_END    DATE,
          POSITION         NUMBER
) ON COMMIT PRESERVE ROWS
