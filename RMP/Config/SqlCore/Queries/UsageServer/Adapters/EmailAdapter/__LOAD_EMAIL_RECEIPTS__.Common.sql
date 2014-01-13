
        SELECT id_acc, email_sent, n_failed_attempts
        FROM t_email_adapter_tracking
        WHERE id_instance = %%INSTANCE_ID%%
      