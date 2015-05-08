-- upgrade script for esr-5770
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE
table_exists NUMBER;
v_sql LONG;
BEGIN
SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name=UPPER('t_sch_email_entity_mapping');
IF(table_exists <= 0) THEN
 v_sql := 'CREATE TABLE t_sch_email_entity_mapping
              (
                id_sch_email_entity_mapping NUMBER(10) NOT NULL,
                column_name NVARCHAR2(50) NOT NULL,
                tx_desc NVARCHAR2(200) NULL,
                CONSTRAINT PK_t_sch_email_entity_mapping PRIMARY KEY (id_sch_email_entity_mapping)
              )';
  EXECUTE IMMEDIATE v_sql;
END IF;
END;
/

DECLARE
nCount NUMBER;
BEGIN
SELECT COUNT(*) INTO nCount FROM t_sch_email_entity_mapping;
IF(nCount <= 0) THEN
  INSERT INTO t_sch_email_entity_mapping (id_sch_email_entity_mapping, column_name, tx_desc) VALUES (1, 'c_CreditNote_Id', 'Refers to t_be_cor_cre_creditnote.c_CreditNote_Id');
END IF;
END;
/

DECLARE
table_exists NUMBER;
v_sql LONG;
BEGIN
SELECT count(*) into table_exists FROM user_tables WHERE table_name=UPPER('t_sch_email_adapter_status');
IF(table_exists <= 0) THEN
 v_sql := 'CREATE TABLE t_sch_email_adapter_status
              (
                id_sch_email_adapter_status NUMBER(10) NOT NULL,
                id_entity_guid RAW(16) NULL,
                id_entity_int NUMBER(10) NULL,
                id_sch_email_entity_mapping NUMBER(10) NOT NULL,
                id_event NUMBER(10) NOT NULL,
                email_status NVARCHAR2(20) NOT NULL,
                id_last_run NUMBER(10) NOT NULL,
                retry_counter NUMBER(10) NOT NULL,
                tx_detail NVARCHAR2(2000) NULL,
                CONSTRAINT PK_t_sch_email_adapter_status PRIMARY KEY (id_sch_email_adapter_status),
                CONSTRAINT FK1_t_sch_email_adapter_status FOREIGN KEY (id_sch_email_entity_mapping) REFERENCES t_sch_email_entity_mapping (id_sch_email_entity_mapping),
                CONSTRAINT FK2_t_sch_email_adapter_status FOREIGN KEY (id_event) REFERENCES t_recevent (id_event),
                CONSTRAINT FK3_t_sch_email_adapter_status FOREIGN KEY (id_last_run) REFERENCES t_recevent_run (id_run)
              )';
  EXECUTE IMMEDIATE v_sql;
END IF;
END;
/

DECLARE
nCount NUMBER;
v_sql LONG;
BEGIN
SELECT COUNT(*) INTO nCount FROM user_sequences WHERE sequence_name = UPPER('seq_t_sch_email_adapter_status');                                                           
IF(nCount <= 0) THEN
  v_sql := 'CREATE SEQUENCE seq_t_sch_email_adapter_status increment by 1 start with 1 nocache order nocycle';
EXECUTE IMMEDIATE v_sql;
END IF;
END;
/