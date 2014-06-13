
          create index t_principal_policy_idx1 on t_principal_policy(id_acc, policy_type);

          create index idx_adj_txn_dt_crt_ndel_usage on t_adjustment_transaction (dt_crt, UPPER(c_status), id_sess);

