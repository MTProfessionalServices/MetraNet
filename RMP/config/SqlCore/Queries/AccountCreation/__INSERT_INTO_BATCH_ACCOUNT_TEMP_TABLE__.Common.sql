
          INSERT INTO %%TMP_TABLE_NAME%%
          (
            id_request,
            id_acc_ext,
            acc_state,
            acc_status_ext,
            acc_vtstart,
            acc_vtend,
            nm_login,
            nm_space,
            tx_password,
            langcode,
            profile_timezone,
            id_cycle_type,
            day_of_month,
            day_of_week,
            first_day_of_month,
            second_day_of_month,
            start_day,
            start_month,
            start_year,
            billable,
            id_payer,
            payer_startdate,
            payer_enddate,
            payer_login,
            payer_namespace,
            id_ancestor,
            hierarchy_start,
            hierarchy_end,
            ancestor_name,
            ancestor_namespace,
            acc_type,
            apply_default_policy,
            account_currency,
            id_profile,
            login_app,
            id_account
          )
          VALUES
          (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
            ?, ?, ?, ?, ?, ?
          )
      