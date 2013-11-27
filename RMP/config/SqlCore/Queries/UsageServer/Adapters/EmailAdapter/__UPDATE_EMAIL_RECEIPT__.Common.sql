
        UPDATE t_email_adapter_tracking
        SET
          email_sent = '%%EMAIL_SENT%%',
          n_failed_attempts = %%FAILED_ATTEMPTS%%
        WHERE
          id_acc = %%ACCOUNT_ID%%  AND 
          id_instance = %%INSTANCE_ID%%
      