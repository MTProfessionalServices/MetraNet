
										create table tmp_t_acc_usage (
										id_sess NUMBER(20),
										id_usage_interval number(10),
										id_acc number(10));
										create unique index idx_tmp_t_acc_usage on tmp_t_acc_usage
										(id_sess,id_usage_interval);
										create index idx1_tmp_t_acc_usage on tmp_t_acc_usage(id_acc);

										create table tmp_t_adjustment_transaction
										(id_adj_trx NUMBER(10) unique);

										create table tmp_adjustment(name nvarchar2(2000));

										create table tmp_id_view(id_view number(10));

										create table tmp_t_adjust_txn_temp(id_sess number(20));
