drop table narrow;
drop table wider;
drop table wide;
create table narrow
(

number_10_0 number(10, 0)
--,nvarchar2_255_1 nvarchar2(512)
,varchar2_40_2 varchar2(40)
,number_38_3 number(38, 6)
,number_38_4 number(38, 6)
,number_38_5 number(38, 6)
,number_38_6 number(38, 6)
--,nvarchar2_255_7 nvarchar2(255)
--,nvarchar2_255_8 nvarchar2(255)
--,nvarchar2_255_9 nvarchar2(255)
--,nvarchar2_255_10 nvarchar2(255)
,raw_40_11 raw(40)
/*
,raw_40_12 raw(40)
,raw_40_13 raw(40)
,raw_40_14 raw(40)
,number_10_15 number(38, 6)
,number_10_16 number(38, 6)
,number_10_17 number(38, 6)
,number_10_18 number(38, 6)
,datetime_10_19 date
,datetime_10_20 date
,datetime_10_21 date
*/
);

create table wider
(

number_10_0 number(10, 0)
,nvarchar2_255_1 nvarchar2(512)
,varchar2_40_2 varchar2(40)
,number_38_3 number(38, 6)
,number_38_4 number(38, 6)
,number_38_5 number(38, 6)
,number_38_6 number(38, 6)
,nvarchar2_255_7 nvarchar2(512)
--,nvarchar2_255_8 nvarchar2(255)
--,nvarchar2_255_9 nvarchar2(255)
--,nvarchar2_255_10 nvarchar2(255)
,raw_40_11 raw(40)
/*
,raw_40_12 raw(40)
,raw_40_13 raw(40)
,raw_40_14 raw(40)
,number_10_15 number(38, 6)
,number_10_16 number(38, 6)
,number_10_17 number(38, 6)
,number_10_18 number(38, 6)
,datetime_10_19 date
,datetime_10_20 date
,datetime_10_21 date
*/
);

create table wide
(

number_10_0 number(10, 0)
,nvarchar2_255_1 nvarchar2(512)
,varchar2_40_2 varchar2(40)
,number_38_3 number(38, 6)
,number_38_4 number(38, 6)
,number_38_5 number(38, 6)
,number_38_6 number(38, 6)
,nvarchar2_255_7 nvarchar2(512)
,nvarchar2_255_8 nvarchar2(512)
,raw_40_11 raw(40)
,raw_40_12 raw(40)
,raw_40_13 raw(40)
,raw_40_14 raw(40)
,number_10_15 number(38, 6)
,number_10_16 number(38, 6)
,number_10_17 number(38, 6)
,number_10_18 number(38, 6)
,datetime_10_19 date
,datetime_10_20 date
,datetime_10_21 date
)


