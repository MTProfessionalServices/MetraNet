create table t_updatestats_partition
(
partname nvarchar2(2000),
last_stats_time date,
partition_status char(1),
Usage_Sampling_Ratio number(10),
Non_Usage_Sampling_Ratio number(10),
H_Sampling_Ratio number(10)
)