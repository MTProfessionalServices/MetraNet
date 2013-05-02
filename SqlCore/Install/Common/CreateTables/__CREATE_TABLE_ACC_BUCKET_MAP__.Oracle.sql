
        create table t_acc_bucket_map
        (id_usage_interval number(10) not null,
        id_acc number(10) not null,
        bucket number(10) not null,
        status char(1) not null,
        tt_start date not null,
        tt_end date not null);
        create unique index idx_t_acc_bucket_map on t_acc_bucket_map(id_acc,id_usage_interval,bucket,status,tt_end);
        create index idx1_t_acc_bucket_map on t_acc_bucket_map(id_usage_interval,bucket,status);

