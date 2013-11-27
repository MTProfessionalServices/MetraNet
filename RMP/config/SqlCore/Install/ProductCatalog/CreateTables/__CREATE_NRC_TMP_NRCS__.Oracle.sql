
CREATE GLOBAL TEMPORARY TABLE tmp_nrcs 
( 
          ID_PROP          NUMBER(10),
          N_EVENT_TYPE     NUMBER(10),
          ID_PI_INSTANCE   NUMBER(10),
          ID_PI_TEMPLATE   NUMBER(10),
          ID_PO            NUMBER(10),
          ID_ACC           NUMBER(10),
          ID_SUB           NUMBER(10),
          POSITION         NUMBER,
          VT_START         DATE,
          VT_END           DATE,
          TT_START         DATE,
          TT_END           DATE,
          MAX_VT_TT_START  DATE,
          MAX_VT_TT_END    DATE,
          DT_ARG_START     DATE,
          DT_ARG_END      DATE
) ON COMMIT PRESERVE ROWS
