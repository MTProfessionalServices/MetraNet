
insert into t_account (id_acc, id_acc_ext, id_type, dt_crt)
values (1, sys_guid(), 1, to_date('01-JAN-1753', 'DD-MON-YYYY'));

insert into t_account (id_acc, id_acc_ext, id_type, dt_crt)
values (-1, sys_guid(), 1, to_date('01-JAN-1753', 'DD-MON-YYYY'));

