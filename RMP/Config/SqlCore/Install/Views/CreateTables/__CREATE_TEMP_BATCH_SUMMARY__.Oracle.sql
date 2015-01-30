
  create global temporary table t_batch_summary
  (
    tx_batch raw(16) NOT NULL,
    tx_batch_encoded varchar2(24) NOT NULL,
    n_completed number(10) not null
  )
  on commit preserve rows
