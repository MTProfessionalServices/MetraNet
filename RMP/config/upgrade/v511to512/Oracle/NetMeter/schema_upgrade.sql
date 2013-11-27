select seq_t_sys_upgrade.nextval from dual;

INSERT INTO t_sys_upgrade
(upgrade_id,target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
(seq_t_sys_upgrade.nextval,'5.1.2', sysdate, 'R');

commit;

-- drop existing global temporary tables
DROP TABLE tmp_svc_relations CASCADE CONSTRAINTS;
DROP TABLE tmp_aggregate CASCADE CONSTRAINTS;
DROP TABLE tmp_aggregate_large CASCADE CONSTRAINTS;
DROP TABLE tmp_child_session_sets CASCADE CONSTRAINTS;
DROP TABLE tmp_session CASCADE CONSTRAINTS;
DROP TABLE tmp_session_set CASCADE CONSTRAINTS;
DROP TABLE tmp_message CASCADE CONSTRAINTS;

-- create new tables
CREATE TABLE TTT_TMP_SVC_RELATIONS
(
  TX_ID                 VARCHAR2(169)           NOT NULL,
  ID_SVC         NUMBER(10),
  PARENT_ID_SVC  NUMBER(10),
  CONSTRAINT PK_tmp_svc_relations PRIMARY KEY(tx_id, id_svc)
);

CREATE TABLE TTT_TMP_AGGREGATE
(
  TX_ID                  VARCHAR2(169 BYTE)     NOT NULL,
  ID_SESS                NUMBER(10)             NOT NULL,
  ID_PARENT_SOURCE_SESS  RAW(16),
  SESSIONS_IN_COMPOUND   NUMBER(10),
  CONSTRAINT PK_ttt_tmp_aggregate PRIMARY KEY(tx_id, id_sess)
);

CREATE TABLE TTT_TMP_AGGREGATE_LARGE
(
  TX_ID   VARCHAR2(169) NOT NULL,
  id_sess number(10) not null,
  id_parent_source_sess raw(16),
  sessions_in_compound number(10),
  CONSTRAINT PK_ttt_tmp_agg_large PRIMARY KEY(tx_id, id_sess)
);

CREATE TABLE TTT_TMP_CHILD_SESSION_SETS
(
  TX_ID   VARCHAR2(169) NOT NULL,
  id_sess number(10) not null,
  id_parent_sess number(10) not null,
  id_svc number(10) not null,
  cnt number(10),
  CONSTRAINT PK_ttt_tmp_child_session_sets PRIMARY KEY(tx_id, id_parent_sess, id_svc)
);

CREATE TABLE TTT_TMP_SESSION
(
  TX_ID   VARCHAR2(169) NOT NULL,
  id_ss number(10) NOT NULL,
  id_source_sess raw(16) NOT NULL,  
  CONSTRAINT pk_ttt_tmp_session PRIMARY KEY (tx_id, id_ss, id_source_sess)
);

CREATE TABLE TTT_TMP_SESSION_SET
(
  TX_ID   VARCHAR2(169) NOT NULL,
  id_message number(10) NOT NULL,
  id_ss number(10) NOT NULL,
  id_svc number(10) NOT NULL,
  b_root CHAR(1) NOT NULL,
  session_count number(10) NOT NULL,
  CONSTRAINT pk_ttt_tmp_session_set PRIMARY KEY(tx_id, id_ss) 
);

CREATE TABLE TTT_TMP_MESSAGE
(
  TX_ID       VARCHAR2(169)           NOT NULL,
  ID_MESSAGE  NUMBER(10),
  CONSTRAINT PK_TTT_TMP_MESSAGE PRIMARY KEY (TX_ID, ID_MESSAGE)            
);

--create triggers
CREATE OR REPLACE TRIGGER TRG_TMP_SVC_RELATIONS
BEFORE INSERT ON TTT_TMP_SVC_RELATIONS
FOR EACH ROW
BEGIN
   :NEW.tx_id := mt_ttt.get_tx_id();
END;              
/

CREATE OR REPLACE TRIGGER TRG_TTT_TMP_AGGREGATE
BEFORE INSERT ON TTT_TMP_AGGREGATE
FOR EACH ROW
BEGIN
   :NEW.tx_id := mt_ttt.get_tx_id();
END;
/

CREATE OR REPLACE TRIGGER TRG_TMP_AGGREGATE_LARGE
BEFORE INSERT ON TTT_TMP_AGGREGATE_LARGE
FOR EACH ROW
BEGIN
   :NEW.tx_id := mt_ttt.get_tx_id();
END;             
/

CREATE OR REPLACE TRIGGER TRG_TMP_CHILD_SESSION_SETS
BEFORE INSERT ON TTT_TMP_CHILD_SESSION_SETS
FOR EACH ROW
BEGIN
   :NEW.tx_id := mt_ttt.get_tx_id();
END;             
/

CREATE OR REPLACE TRIGGER TRG_TMP_SESSION
BEFORE INSERT ON TTT_TMP_SESSION
FOR EACH ROW
BEGIN
   :NEW.tx_id := mt_ttt.get_tx_id();
END;             
/

CREATE OR REPLACE TRIGGER TRG_TMP_SESSION_SET
BEFORE INSERT ON TTT_TMP_SESSION_SET
FOR EACH ROW
BEGIN
   :NEW.tx_id := mt_ttt.get_tx_id();
END;            
/

CREATE OR REPLACE TRIGGER TRG_TTT_TMP_MESSAGE
BEFORE INSERT ON TTT_TMP_MESSAGE
FOR EACH ROW
BEGIN
   :NEW.tx_id := mt_ttt.get_tx_id();
END;            
/

-- create views
CREATE VIEW TMP_SVC_RELATIONS
  AS
  SELECT id_svc,
  parent_id_svc
  FROM TTT_TMP_SVC_RELATIONS
  WHERE tx_id = mt_ttt.get_tx_id();

CREATE OR REPLACE VIEW TMP_AGGREGATE
AS
   SELECT 
       ID_SESS, 
       ID_PARENT_SOURCE_SESS, 
       SESSIONS_IN_COMPOUND
   FROM ttt_tmp_aggregate
   WHERE tx_id = mt_ttt.get_tx_id();

CREATE VIEW TMP_AGGREGATE_LARGE
AS
   SELECT 
    ID_SESS,
    ID_PARENT_SOURCE_SESS,
    SESSIONS_IN_COMPOUND   
     FROM TTT_TMP_AGGREGATE_LARGE
    WHERE tx_id = mt_ttt.get_tx_id();

CREATE VIEW TMP_CHILD_SESSION_SETS
AS
 SELECT
 ID_SESS,
 ID_PARENT_SESS,
 ID_SVC,
 CNT
 FROM TTT_TMP_CHILD_SESSION_SETS
 WHERE tx_id = mt_ttt.get_tx_id();

CREATE VIEW TMP_SESSION
AS
   SELECT 
    ID_SS,
    ID_SOURCE_SESS   
     FROM TTT_TMP_SESSION
    WHERE tx_id = mt_ttt.get_tx_id();

CREATE VIEW TMP_SESSION_SET
AS
   SELECT 
    ID_MESSAGE,
    ID_SS,
    ID_SVC,
    B_ROOT,
    SESSION_COUNT   
     FROM TTT_TMP_SESSION_SET
    WHERE tx_id = mt_ttt.get_tx_id();

CREATE VIEW TMP_MESSAGE
AS
   SELECT ID_MESSAGE
     FROM TTT_TMP_MESSAGE
    WHERE tx_id = mt_ttt.get_tx_id();


-- update the t_sys_upgrade
UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = sysdate
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade);

commit;

