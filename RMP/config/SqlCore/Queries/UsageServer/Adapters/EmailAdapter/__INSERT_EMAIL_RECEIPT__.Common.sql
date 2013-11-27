
        INSERT INTO t_email_adapter_tracking
          (id_acc, email_sent, n_failed_attempts, id_instance)
        VALUES
          (%%ACCOUNT_ID%%, '%%EMAIL_SENT%%', %%FAILED_ATTEMPTS%%, %%INSTANCE_ID%%)
      