
CREATE OR REPLACE PROCEDURE MTSP_DM_CALLDTLSUBTTL_DDLCRE
AS
BEGIN
/*  Summary table for t_account_ancestor for reporting */
EXECUTE IMMEDIATE (
'CREATE TABLE DM_T_SUM_GEN1 
(id_ancestor NUMBER(38),
 a_folderind CHAR(1),
 a_firstname VARCHAR2(200),
 a_lastname VARCHAR2(200),
 id_descendent NUMBER(38),
 d_folderind CHAR(1),
 d_firstname VARCHAR2(200),
 d_lastname VARCHAR2(200),
 vt_start DATE,
 vt_end DATE)');

EXECUTE IMMEDIATE (
'CREATE TABLE DM_T_SUM_ACC_GEN_FLAT ( 
  gen_0           number (38) not null, 
  vt_start        date, 
  vt_end          date,
  gen_0_folder_flag char(1),
  gen_0_firstname	varchar2 (40),
  gen_0_lastname  varchar2 (40), 
  gen_1		number (38), 
  gen_1_folder_flag char(1),
  gen_1_firstname	varchar2 (40),
  gen_1_lastname  varchar2 (40), 
  gen_2		number (38), 
  gen_2_folder_flag char(1),
  gen_2_firstname	varchar2 (40),
  gen_2_lastname  varchar2 (40), 
  gen_3		number (38), 
  gen_3_folder_flag char(1),
  gen_3_firstname	varchar2 (40),
  gen_3_lastname  varchar2 (40), 
  gen_4		number (38), 
  gen_4_folder_flag char(1),
  gen_4_firstname	varchar2 (40),
  gen_4_lastname  varchar2 (40), 
  gen_5		number (38), 
  gen_5_folder_flag char(1),
  gen_5_firstname	varchar2 (40),
  gen_5_lastname  varchar2 (40), 
  gen_6		number (38), 
  gen_6_folder_flag char(1),
  gen_6_firstname	varchar2 (40),
  gen_6_lastname  varchar2 (40), 
  gen_7		number (38), 
  gen_7_folder_flag char(1),
  gen_7_firstname	varchar2 (40),
  gen_7_lastname  varchar2 (40), 
  gen_8		number (38), 
  gen_8_folder_flag char(1),
  gen_8_firstname	varchar2 (40),
  gen_8_lastname  varchar2 (40), 
  gen_9		number (38), 
  gen_9_folder_flag char(1),
  gen_9_firstname	varchar2 (40),
  gen_9_lastname  varchar2 (40), 
  gen_10		number (38), 
  gen_10_folder_flag char(1),
  gen_10_firstname	varchar2 (40),
  gen_10_lastname  varchar2 (40))') ; 

EXECUTE IMMEDIATE (
'CREATE TABLE DM_T_SUM_ACC_GEN_FLAT_S1 ( 
  gen_0		number(38) not null, 
  vt_start	date, 
  vt_end	date,
  stitle_0	char(1),
  firstname_0	varchar2 (40),
  lastname_0	varchar2 (40), 
  gen_1		number(38), 
  stitle_1	char(1),
  firstname_1	varchar2 (40),
  lastname_1	varchar2 (40), 
  gen_2		number(38), 
  stitle_2	char(1),
  firstname_2	varchar2 (40),
  lastname_2	varchar2 (40), 
  gen_3		number(38), 
  stitle_3	char(1),
  firstname_3	varchar2 (40),
  lastname_3	varchar2 (40), 
  gen_4		number(38), 
  stitle_4	char(1),
  firstname_4	varchar2 (40),
  lastname_4	varchar2 (40), 
  gen_5		number(38), 
  stitle_5	char(1),
  firstname_5	varchar2 (40),
  lastname_5	varchar2 (40))');

EXECUTE IMMEDIATE (
'CREATE TABLE DM_T_SUM_ACC_LVL_FLAT ( 
  gen_0		number(38),
  top_lvl_1       number (38), 
  top_lvl_1_desc  varchar2 (200), 
  top_lvl_2       number (38), 
  top_lvl_2_desc  varchar2 (200), 
  top_lvl_3       number (38), 
  top_lvl_3_desc  varchar2 (200), 
  top_lvl_4       number (38), 
  top_lvl_4_desc  varchar2 (200), 
  top_lvl_5       number (38), 
  top_lvl_5_desc  varchar2 (200), 
  top_lvl_6       number (38), 
  top_lvl_6_desc  varchar2 (200), 
  top_lvl_7       number (38), 
  top_lvl_7_desc  varchar2 (200), 
  top_lvl_8       number (38), 
  top_lvl_8_desc  varchar2 (200), 
  top_lvl_9       number (38), 
  top_lvl_9_desc  varchar2 (200), 
  top_lvl_10       number (38), 
  top_lvl_10_desc  varchar2 (200), 
  vt_start           date, 
  vt_end             date)') ;

/*  create the report result data table */
EXECUTE IMMEDIATE (
'CREATE TABLE DM_T_RPTRST_CALLDTL_DETAIL
(id_rpt number(38),
 top_lvl_1 number(38), top_lvl_1_desc varchar2(200), 
 top_lvl_2 number(38), top_lvl_2_desc varchar2(200), 
 top_lvl_3 number(38), top_lvl_3_desc varchar2(200), 
 top_lvl_4 number(38), top_lvl_4_desc varchar2(200), 
 top_lvl_5 number(38), top_lvl_5_desc varchar2(200), 
 top_lvl_6 number(38), top_lvl_6_desc varchar2(200),
 top_lvl_7 number(38), top_lvl_7_desc varchar2(200),
 top_lvl_8 number(38), top_lvl_8_desc varchar2(200),
 top_lvl_9 number(38), top_lvl_9_desc varchar2(200),
 top_lvl_10 number(38), top_lvl_10_desc varchar2(200),
 id_acc number(38) not null, 
 id_payee number(38) not null,
 id_sess number(38) not null,
 id_parent_sess number(38) null,
 c_calldate char(11),
 c_calltime char(15),
 c_calllength varchar2(30),
 c_callprice number(22,10),
 lvl_num number(38))'); 

/*  create the report result parent table */
EXECUTE IMMEDIATE (
'CREATE TABLE DM_T_RPTRST_CALLDTL_PARENT
(id_rpt number(38) not null,
 by_id_acc number(38) not null,
 rpt_dt_start date not null,
 rpt_dt_end date null,
 rpt_name varchar2(500),
 rpt_status char(1) not null, 
 parm_dt_start date not null,
 parm_dt_end date,
 parm_id_acc_for number(38),
 rpt_acc_name_for varchar2(100),
 rpt_err_desc varchar2(1000),
 primary key (id_rpt))');

EXECUTE IMMEDIATE (
'CREATE SEQUENCE seq_dm_rpt_calldtl INCREMENT BY 1 START WITH 1 MINVALUE 1');

EXECUTE IMMEDIATE (
'ALTER TABLE dm_t_rptrst_calldtl_detail ADD CONSTRAINT rptrst_calldtl_dtl_FK1
 FOREIGN KEY (ID_RPT) 
  REFERENCES dm_t_rptrst_calldtl_parent (ID_RPT)') ;

EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_SUM_ACCGENFLAT_1 ON DM_T_SUM_ACC_GEN_FLAT(GEN_0)');
EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_SUM_ACCGENFLAT_2 ON DM_T_SUM_ACC_GEN_FLAT(GEN_1)');
EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_SUM_ACCGENFLAT_3 ON DM_T_SUM_ACC_GEN_FLAT(GEN_2)');
EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_SUM_ACCGENFLAT_4 ON DM_T_SUM_ACC_GEN_FLAT(GEN_3)');
EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_SUM_ACCGENFLAT_5 ON DM_T_SUM_ACC_GEN_FLAT(GEN_4)');
EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_SUM_ACCGENFLAT_6 ON DM_T_SUM_ACC_GEN_FLAT(GEN_5)');
EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_SUM_ACCGENFLAT_7 ON DM_T_SUM_ACC_GEN_FLAT(GEN_6)');
EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_SUM_ACCGENFLAT_8 ON DM_T_SUM_ACC_GEN_FLAT(GEN_7)');
EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_SUM_ACCGENFLAT_9 ON DM_T_SUM_ACC_GEN_FLAT(GEN_8)');
EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_SUM_ACCGENFLAT_10 ON DM_T_SUM_ACC_GEN_FLAT(GEN_9)');
EXECUTE IMMEDIATE ('CREATE INDEX IDX_DM_T_SUM_ACC_LVL_FLAT ON DM_T_SUM_ACC_LVL_FLAT (TOP_LVL_1, GEN_0)');

END MTSP_DM_CALLDTLSUBTTL_DDLCRE;
	   