select * from t_engineers

delete from t_engineers where id_engineer=18

select  distinct tx_department from t_engineers

select * from t_feature

select nm_automation ,* from t_Test order by id_test desc
elete from t_Test  where id_test=68

select * from t_test_run


select * from t_build order by  nm_build


insert into t_build (nm_build,tx_description,is_code_freeze_build )values('MTP-V3.7-20040830','','N')


select * from t_system order by nm_system

select * from t_system where nm_system = ''

select  distinct tx_test_mode  from t_test

sp_help t_system



W2KADVSVR

insert into t_system (nm_system,tx_CPU_speed,tx_RAM,ct_physical_CPU,is_hyperthreaded)values('W2KADVSVR','Xeon 2.4Ghz','1 GB',1,'Y')
insert into t_system (nm_system,tx_CPU_speed,tx_RAM,ct_physical_CPU,is_hyperthreaded)values('W2KADVSVR','Xeon 2.4Ghz','1 GB',1,'Y')

delete  from t_system where nm_system='W2KADVSVR'
delete  from t_system where nm_system='F-TORRES2'

select * from t_system 
--where nm_system='W2KADVSVR'
order by id_system

insert into t_system (nm_system,tx_CPU_speed,tx_RAM,ct_physical_CPU,is_hyperthreaded)values('W2KADVSVR','Xeon 2.4 Ghz','2 GB',1,'Y')




select 
dt_run, nm_build, nm_automation,tx_status,nm_engineer,tr.tx_comments, * 
from t_Test t 
	join t_test_run tr on t.id_test=tr.id_test 
	join t_build b on b.id_build=tr.id_build
	join t_engineers e on e.id_engineer=tr.id_engineer
order by t.id_test desc,tr.id_run desc



http://eng2/TestTracker/



sp_help ReportToQARepository
@TestName	 varchar	255	255	NULL	1	SQL_Latin1_General_CP1_CI_AS
@Build		 varchar	20	20	NULL	2	SQL_Latin1_General_CP1_CI_AS
@Engineer	 varchar	255	255	NULL	3	SQL_Latin1_General_CP1_CI_AS
@ct_failed_cases int	4	10	0	4	NULL
@tx_status	 varchar	255	255	NULL	5	SQL_Latin1_General_CP1_CI_AS
@tx_comments	 varchar	255	255	NULL	6	SQL_Latin1_General_CP1_CI_AS
@SystemName	 varchar	255	255	NULL	7	SQL_Latin1_General_CP1_CI_AS

ReportToQARepository 'FPhone Demo','05042004','Amit K. Verma',0,'Passed','!','W2KADVSVR'

sp_helptext registerTest
Select * from t_test where nm_automation = upper('FPhone Demo')

ReportToQARepository 'ARCHIVE TEST (WITH METRAVIEW DATAMART)','05042004','Amit K. Verma',0,'Passed','MetraNet3.7','W2KADVSVR'
select * from t_test_run order by id_run desc




select * from t_Test order by id_test desc

delete from t_Test  where id_test in(
select * from t_test_run where id_test in(

delete from t_test_run  where id_test in(
57,
56,
55,
54,
53,
52,
50,
51
)


select * from t_feature
select * from t_sub_feature
