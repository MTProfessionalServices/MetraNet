create table t_updatestats_partition
(
partname nvarchar(4000),
last_stats_time datetime,
partition_status char(1),
Usage_Sampling_Ratio int,
Non_Usage_Sampling_Ratio int,
H_Sampling_Ratio int
)