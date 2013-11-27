
CREATE PROCEDURE mtsp_dm_calldtlsubttl_ddlcre
AS
BEGIN
-- Summary table for t_account_ancestor for reporting
CREATE TABLE dm_t_sum_gen1 
(id_ancestor int,
 a_folderind char(1),
 a_firstname varchar(200),
 a_lastname varchar(200),
 id_descendent int,
 d_folderind char(1),
 d_firstname varchar(200),
 d_lastname varchar(200),
 vt_start datetime,
 vt_end datetime)

CREATE TABLE dm_t_sum_acc_gen_flat ( 
  gen_0           int not null, 
  vt_start        datetime, 
  vt_end          datetime,
  gen_0_folder_flag char(1),
  gen_0_firstname	varchar (40),
  gen_0_lastname  varchar (40), 
  gen_1		int, 
  gen_1_folder_flag char(1),
  gen_1_firstname	varchar (40),
  gen_1_lastname  varchar (40), 
  gen_2		int, 
  gen_2_folder_flag char(1),
  gen_2_firstname	varchar (40),
  gen_2_lastname  varchar (40), 
  gen_3		int, 
  gen_3_folder_flag char(1),
  gen_3_firstname	varchar (40),
  gen_3_lastname  varchar (40), 
  gen_4		int, 
  gen_4_folder_flag char(1),
  gen_4_firstname	varchar (40),
  gen_4_lastname  varchar (40), 
  gen_5		int, 
  gen_5_folder_flag char(1),
  gen_5_firstname	varchar (40),
  gen_5_lastname  varchar (40), 
  gen_6		int, 
  gen_6_folder_flag char(1),
  gen_6_firstname	varchar (40),
  gen_6_lastname  varchar (40), 
  gen_7		int, 
  gen_7_folder_flag char(1),
  gen_7_firstname	varchar (40),
  gen_7_lastname  varchar (40), 
  gen_8		int, 
  gen_8_folder_flag char(1),
  gen_8_firstname	varchar (40),
  gen_8_lastname  varchar (40), 
  gen_9		int, 
  gen_9_folder_flag char(1),
  gen_9_firstname	varchar (40),
  gen_9_lastname  varchar (40), 
  gen_10		int, 
  gen_10_folder_flag char(1),
  gen_10_firstname	varchar (40),
  gen_10_lastname  varchar (40))

CREATE TABLE dm_t_sum_acc_gen_flat_s1 ( 
  gen_0		int not null, 
  vt_start	datetime, 
  vt_end	datetime,
  stitle_0	char(1),
  firstname_0	varchar (40),
  lastname_0	varchar (40), 
  gen_1		int, 
  stitle_1	char(1),
  firstname_1	varchar (40),
  lastname_1	varchar (40), 
  gen_2		int, 
  stitle_2	char(1),
  firstname_2	varchar (40),
  lastname_2	varchar (40), 
  gen_3		int, 
  stitle_3	char(1),
  firstname_3	varchar (40),
  lastname_3	varchar (40), 
  gen_4		int, 
  stitle_4	char(1),
  firstname_4	varchar (40),
  lastname_4	varchar (40), 
  gen_5		int, 
  stitle_5	char(1),
  firstname_5	varchar (40),
  lastname_5	varchar (40))

CREATE TABLE dm_t_sum_acc_lvl_flat ( 
  gen_0		int,
  top_lvl_1       int, 
  top_lvl_1_desc  varchar (200), 
  top_lvl_2       int, 
  top_lvl_2_desc  varchar (200), 
  top_lvl_3       int, 
  top_lvl_3_desc  varchar (200), 
  top_lvl_4       int, 
  top_lvl_4_desc  varchar (200), 
  top_lvl_5       int, 
  top_lvl_5_desc  varchar (200), 
  top_lvl_6       int, 
  top_lvl_6_desc  varchar (200), 
  top_lvl_7       int, 
  top_lvl_7_desc  varchar (200), 
  top_lvl_8       int, 
  top_lvl_8_desc  varchar (200), 
  top_lvl_9       int, 
  top_lvl_9_desc  varchar (200), 
  top_lvl_10       int, 
  top_lvl_10_desc  varchar (200), 
  vt_start           datetime, 
  vt_end             datetime)

-- create the report result data table
CREATE TABLE dm_t_rptrst_calldtl_detail
(id_rpt int,
 top_lvl_1 int, top_lvl_1_desc varchar(200), 
 top_lvl_2 int, top_lvl_2_desc varchar(200), 
 top_lvl_3 int, top_lvl_3_desc varchar(200), 
 top_lvl_4 int, top_lvl_4_desc varchar(200), 
 top_lvl_5 int, top_lvl_5_desc varchar(200), 
 top_lvl_6 int, top_lvl_6_desc varchar(200),
 top_lvl_7 int, top_lvl_7_desc varchar(200),
 top_lvl_8 int, top_lvl_8_desc varchar(200),
 top_lvl_9 int, top_lvl_9_desc varchar(200),
 top_lvl_10 int, top_lvl_10_desc varchar(200),
 id_acc int not null,
 id_payee int not null,
 id_sess bigint not null,
 id_parent_sess bigint null,
 c_calldate char(11),
 c_calltime char(15),
 c_calllength varchar(30),
 c_callprice decimal(22,10),
 lvl_num int)

-- create the report result parent table
CREATE TABLE dm_t_rptrst_calldtl_parent
(id_rpt int identity (1,1) not null,
 by_id_acc int not null,
 rpt_dt_start datetime not null,
 rpt_dt_end datetime null,
 rpt_name varchar(500),
 rpt_status char(1) not null, 
 parm_dt_start datetime not null,
 parm_dt_end datetime,
 parm_id_acc_for int,
 rpt_acc_name_for varchar(100),
 rpt_err_desc varchar(1000),
 primary key (id_rpt))

ALTER TABLE dm_t_rptrst_calldtl_detail ADD CONSTRAINT rptrst_calldtl_dtl_FK1
 FOREIGN KEY (id_rpt) 
  REFERENCES dm_t_rptrst_calldtl_parent (id_rpt)

CREATE INDEX idx_dm_sum_accgenflat_1 ON dm_t_sum_acc_gen_flat(gen_0)
CREATE INDEX idx_dm_sum_accgenflat_2 ON dm_t_sum_acc_gen_flat(gen_1)
CREATE INDEX idx_dm_sum_accgenflat_3 ON dm_t_sum_acc_gen_flat(gen_2)
CREATE INDEX idx_dm_sum_accgenflat_4 ON dm_t_sum_acc_gen_flat(gen_3)
CREATE INDEX idx_dm_sum_accgenflat_5 ON dm_t_sum_acc_gen_flat(gen_4)
CREATE INDEX idx_dm_sum_accgenflat_6 ON dm_t_sum_acc_gen_flat(gen_5)
CREATE INDEX idx_dm_sum_accgenflat_7 ON dm_t_sum_acc_gen_flat(gen_6)
CREATE INDEX idx_dm_sum_accgenflat_8 ON dm_t_sum_acc_gen_flat(gen_7)
CREATE INDEX idx_dm_sum_accgenflat_9 ON dm_t_sum_acc_gen_flat(gen_8)
CREATE INDEX idx_dm_sum_accgenflat_10 ON dm_t_sum_acc_gen_flat(gen_9)
CREATE INDEX idx_dm_t_sum_acc_lvl_flat ON dm_t_sum_acc_lvl_flat (top_lvl_1, gen_0)

END
	   