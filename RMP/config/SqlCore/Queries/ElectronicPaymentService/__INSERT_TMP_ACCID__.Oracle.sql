
            INSERT INTO t_payment_instrument_xref
            (
              temp_acc_id,
              nm_login,
              nm_space,
              dt_created
            )
            VALUES
            (
              %%TEMP_ACCT_ID%%,
              N'%%NM_LOGIN%%',
              N'%%NM_SPACE%%',
              %%DT_CREATED%%
            )
	  