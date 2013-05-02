
            CREATE global temporary TABLE TMP_T_ADJSTMNT_TRANS
            (
              ID_ADJ_TRX         NUMBER(10)                 NOT NULL,
              ID_SESS            NUMBER(10),
              ID_PARENT_SESS     NUMBER(10),
              ID_REASON_CODE     NUMBER(10)                 NOT NULL,
              ID_ACC_CREATOR     NUMBER(10)                 NOT NULL,
              ID_ACC_PAYER       NUMBER(10)                 NOT NULL,
              C_STATUS           VARCHAR2(10)               NOT NULL,
              N_ADJUSTMENTTYPE   NUMBER(10)                 NOT NULL,
              DT_CRT             DATE                       NOT NULL,
              DT_MODIFIED        DATE                       NOT NULL,
              ID_AJ_TEMPLATE     NUMBER(10),
              ID_AJ_INSTANCE     NUMBER(10),
              ID_AJ_TYPE         NUMBER(10)                 NOT NULL,
              ID_USAGE_INTERVAL  NUMBER(10)                 NOT NULL,
              ADJUSTMENTAMOUNT   NUMBER(22,10)               NOT NULL,
              AJ_TAX_FEDERAL     NUMBER(22,10)               NOT NULL,
              AJ_TAX_STATE       NUMBER(22,10)               NOT NULL,
              AJ_TAX_COUNTY      NUMBER(22,10)               NOT NULL,
              AJ_TAX_LOCAL       NUMBER(22,10)               NOT NULL,
              AJ_TAX_OTHER       NUMBER(22,10)               NOT NULL,
              AM_CURRENCY        NVARCHAR2(3)               NOT NULL,
              TX_DEFAULT_DESC    NVARCHAR2(1900),
              TX_DESC            NVARCHAR2(1900),
              ARBATCHID          VARCHAR2(15),
              ARDELBATCHID       VARCHAR2(15),
              ARDELACTION        CHAR(1),
              ARCHIVE_SESS       NUMBER(10)
            ) on commit preserve rows
            