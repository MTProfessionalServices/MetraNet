
        insert into t_acc_template_session_detail(id_detail, id_session, n_detail_type, n_result, dt_Detail, nm_text, n_retry_count) values
        (seq_template_session_detail.NEXTVAL, %%SESSION_ID%%, %%DETAIL_TYPE%%, %%RESULT%%, %%DETAIL_DATE%%, '%%TEXT%%', '%%RETRY_COUNT%%')
			