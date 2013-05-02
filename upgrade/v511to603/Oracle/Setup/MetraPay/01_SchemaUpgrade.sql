/*
*********** New tables
*/

CREATE TABLE T_PS_PREAUTH
(
  ID_PREAUTH_TX_ID    VARCHAR2(40 BYTE)         NOT NULL,
  ID_PYMT_INSTRUMENT  VARCHAR2(40 BYTE)         NOT NULL,
  DT_TRANSACTION      TIMESTAMP(6)              NOT NULL,
  NM_INVOICE_NUM      NVARCHAR2(255),
  DT_INVOICE_DATE     TIMESTAMP(6),
  NM_PO_NUMBER        NVARCHAR2(20),
  NM_DESCRIPTION      NVARCHAR2(10),
  N_CURRENCY          NVARCHAR2(10)             NOT NULL,
  N_AMOUNT            INTEGER                   NOT NULL,
  N_REQUEST_PARAMS    NVARCHAR2(256)            NOT NULL
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

ALTER TABLE T_PS_PREAUTH
 ADD PRIMARY KEY
 (ID_PREAUTH_TX_ID);



CREATE TABLE T_PS_CREDIT_CARD
(
  ID_PAYMENT_INSTRUMENT   VARCHAR2(40 BYTE)     NOT NULL,
  N_CREDIT_CARD_TYPE      NUMBER(10)            NOT NULL,
  NM_EXPIRATIONDT         VARCHAR2(20 BYTE)     NOT NULL,
  NM_EXPIRATIONDT_FORMAT  NUMBER(10)            NOT NULL,
  NM_STARTDATE            VARCHAR2(20 BYTE),
  NM_ISSUERNUMBER         VARCHAR2(20 BYTE)
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

ALTER TABLE T_PS_CREDIT_CARD
 ADD PRIMARY KEY
 (ID_PAYMENT_INSTRUMENT);


CREATE TABLE T_PS_PAYMENT_INSTRUMENT
(
  ID_PAYMENT_INSTRUMENT  VARCHAR2(40 BYTE)      NOT NULL,
  N_PAYMENT_METHOD_TYPE  NUMBER(10)             NOT NULL,
  NM_ACCOUNT_NUMBER      VARCHAR2(2048 BYTE),
  NM_FIRST_NAME          NVARCHAR2(50)          NOT NULL,
  NM_MIDDLE_NAME         NVARCHAR2(50)          NOT NULL,
  NM_LAST_NAME           NVARCHAR2(50)          NOT NULL,
  NM_ADDRESS1            NVARCHAR2(255)         NOT NULL,
  NM_ADDRESS2            NVARCHAR2(255),
  NM_CITY                NVARCHAR2(20)          NOT NULL,
  NM_STATE               NVARCHAR2(20),
  NM_ZIP                 NVARCHAR2(10),
  ID_COUNTRY             NUMBER(10)             NOT NULL
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

ALTER TABLE T_PS_PAYMENT_INSTRUMENT
 ADD PRIMARY KEY
 (ID_PAYMENT_INSTRUMENT);


CREATE TABLE T_PS_AUDIT
(
  ID_AUDIT               VARCHAR2(40 BYTE)      NOT NULL,
  ID_REQUEST_TYPE        NUMBER(10)             NOT NULL,
  ID_TRANSACTION         NVARCHAR2(50)          NOT NULL,
  DT_TRANSACTION         TIMESTAMP(6)           NOT NULL,
  N_PAYMENT_METHOD_TYPE  NUMBER(10)             NOT NULL,
  NM_TRUNCD_ACCT_NUM     NVARCHAR2(20)          NOT NULL,
  N_CREDITCARD_TYPE      NUMBER(10),
  N_ACCOUNT_TYPE         NUMBER(10),
  NM_INVOICE_NUM         NVARCHAR2(50),
  DT_INVOICE_DATE        TIMESTAMP(6),
  NM_PO_NUMBER           NVARCHAR2(30),
  NM_DESCRIPTION         NVARCHAR2(100)         NOT NULL,
  N_CURRENCY             NVARCHAR2(10)          NOT NULL,
  N_AMOUNT               NUMBER(18,6)           NOT NULL
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

ALTER TABLE T_PS_AUDIT
 ADD PRIMARY KEY
 (ID_AUDIT);


/*
ALTER TABLE T_PS_ACH
 DROP CONSTRAINT SYS_C002975340;
*/
DECLARE
   l_table_name varchar2(30) := 'T_PS_ACH';
   CURSOR fk_cur
   IS
    select constraint_name 
    from user_constraints 
    where 
      constraint_type = 'R'
      and table_name = l_table_name;     
BEGIN
   FOR fk_rec IN fk_cur 
   LOOP
      dbms_output.put_line('dropping constraint ' || fk_rec.constraint_name || ' on table ' || l_table_name);
      execute immediate 'alter table ' || l_table_name || ' drop constraint ' || fk_rec.constraint_name; 
   END LOOP;
END;
/

/*
 ALTER TABLE T_PS_PCARD
 DROP CONSTRAINT SYS_C002975328;
*/
DECLARE
   l_table_name varchar2(30) := 'T_PS_PCARD';
   CURSOR fk_cur
   IS
    select constraint_name 
    from user_constraints 
    where 
      constraint_type = 'R'
      and table_name = l_table_name;     
BEGIN
   FOR fk_rec IN fk_cur 
   LOOP
      dbms_output.put_line('dropping constraint ' || fk_rec.constraint_name || ' on table ' || l_table_name);
      execute immediate 'alter table ' || l_table_name || ' drop constraint ' || fk_rec.constraint_name; 
   END LOOP;
END;
/

/*
*********** Delete tables
*/

DROP TABLE T_PS_ACCOUNT CASCADE CONSTRAINTS;

--DROP TABLE T_PS_CREDITCARD CASCADE CONSTRAINTS;
alter table
   T_PS_CREDITCARD
rename to
   T_PS_CREDITCARD_OLD;


exit;
