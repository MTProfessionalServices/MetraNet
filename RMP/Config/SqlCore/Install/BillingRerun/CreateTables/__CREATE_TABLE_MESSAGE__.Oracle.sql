
           CREATE TABLE TTT_TMP_MESSAGE
            (
              TX_ID       VARCHAR2(169)           NOT NULL,
              ID_MESSAGE  NUMBER(10),
             CONSTRAINT PK_TTT_TMP_MESSAGE PRIMARY KEY (TX_ID, ID_MESSAGE)            
            )
            