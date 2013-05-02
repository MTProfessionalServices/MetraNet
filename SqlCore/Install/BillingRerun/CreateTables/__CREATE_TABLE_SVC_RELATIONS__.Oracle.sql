
				        CREATE TABLE TTT_TMP_SVC_RELATIONS
                (
                  TX_ID                 VARCHAR2(169)           NOT NULL,
                  ID_SVC         NUMBER(10),
                  PARENT_ID_SVC  NUMBER(10),
                  CONSTRAINT PK_tmp_svc_relations PRIMARY KEY(tx_id, id_svc)
                )                
            