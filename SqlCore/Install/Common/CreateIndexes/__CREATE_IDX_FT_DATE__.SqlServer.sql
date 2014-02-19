CREATE INDEX IDX_FT_DATE ON t_failed_transaction(dt_FailureTime DESC) INCLUDE (n_expected)
