
          insert into t_acc_template_session(id_session, id_template_owner, nm_acc_type, dt_submission, id_submitter, nm_host, n_status, n_accts, n_subs)
          values (%%SESSION_ID%%, %%OWNER_ID%%, '%%ACCT_TYPE%%', %%SUBMISSION_DATE%%, %%SUBMITTER_ID%%, '%%HOST_NAME%%', %%STATUS%%, %%NUM_ACCTS%%, %%NUM_SUBS%%)
        