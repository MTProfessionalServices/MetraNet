
create table t_acc_bucket_map
(id_usage_interval int not null,
id_acc int not null,
bucket int not null,
status char(1) not null,
tt_start datetime not null,
tt_end datetime not null)
create unique clustered index idx_t_acc_bucket_map on t_acc_bucket_map(id_acc,id_usage_interval,tt_end)
create index idx1_t_acc_bucket_map on t_acc_bucket_map(id_usage_interval,bucket,status)
    