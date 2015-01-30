
				CREATE TABLE tmp_deletethese
                (
                  ID_ANCESTOR      NUMBER(10)                   NOT NULL,
                  ID_DESCENDENT    NUMBER(10)                   NOT NULL,
                  NUM_GENERATIONS  NUMBER(10)                   NOT NULL,
                  B_CHILDREN       CHAR(1)                      DEFAULT 'N',
                  VT_START         DATE,
                  VT_END           DATE,
                  TX_PATH          VARCHAR2(4000)               NOT NULL
                )
				