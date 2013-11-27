
      /* ES2698 TTT_SUBSCRIBE_BATCH supercedes TMP_SUBSCRIBE_BATCH */     
      /* ES2698 create index that includes tx_id for scoping */      
      CREATE TABLE TTT_SUBSCRIBE_BATCH
      (
      TX_ID                 VARCHAR2(169)           NOT NULL,
      ID_ACC                NUMBER(10)              NOT NULL,
      ID_PO                 NUMBER(10)              NOT NULL,
      ID_GROUP              NUMBER(10)              NOT NULL,
      VT_START              DATE                    NOT NULL,
      VT_END                DATE,
      UNCORRECTED_VT_START  DATE                    NOT NULL,
      UNCORRECTED_VT_END    DATE,
      TT_NOW                DATE                    NOT NULL,
      ID_GSUB_CORP_ACCOUNT  NUMBER(10)              NOT NULL,
      STATUS                NUMBER(10)              NOT NULL,
      ID_AUDIT              NUMBER(10)              NOT NULL,
      ID_EVENT              NUMBER(10)              NOT NULL,
      ID_USERID             NUMBER(10)              NOT NULL,
      ID_ENTITYTYPE         NUMBER(10)              NOT NULL,
      ID_SUB                NUMBER(10),
      NM_DISPLAY_NAME       NVARCHAR2(255)
      );
     
      CREATE INDEX IDX_TMP_SUBSCRIBE_BATCH ON TTT_SUBSCRIBE_BATCH (TX_ID, ID_ACC, ID_GROUP);

