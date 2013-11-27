drop table t_dummy
create table t_dummy 
(

number_10_0 number(10, 0)
,nvarchar2_255_1 nvarchar2(1024)
,varchar2_40_2 varchar2(40)
,number_38_3 number(38, 6)
,number_38_4 number(38, 6)
,number_38_5 number(38, 6)
,number_38_6 number(38, 6)
,nvarchar2_255_7 nvarchar2(1024)
,nvarchar2_255_8 nvarchar2(1024)
,nvarchar2_255_9 nvarchar2(1024)
,nvarchar2_255_10 nvarchar2(1024)
,raw_40_11 raw(40)
,raw_40_12 raw(40)
,raw_40_13 raw(40)
,raw_40_14 raw(40)
,number_10_15 number(38, 100)
,number_10_16 number(38, 100)
,number_10_17 number(38, 100)
,number_10_18 number(38, 100)
,datetime_10_19 date
,datetime_10_20 date
,datetime_10_21 date
)
commit all;
select count(*) from t_dummy
select * from t_dummy
truncate table t_dummy
describe t_dummy
select * from t_prod_view_prop where nm_Space is null           
