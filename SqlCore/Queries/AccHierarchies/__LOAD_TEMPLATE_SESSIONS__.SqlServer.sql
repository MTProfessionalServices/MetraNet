
          select
            sessions.id_Session as SessionId,
            id_template_owner as TemplateOwnerId,
            owner.hierarchyname as TemplateOwnerName,
            nm_acc_type as AccountType,
            dt_submission as SubmissionDate,
            id_submitter as SubmitterID,
            coalesce(submitter.hierarchyname, (select top 1 nm_login from t_account_mapper where id_acc = id_submitter)) as SubmitterName,
            nm_host as ServerName,
            n_status as Status,
            n_accts as NumAccounts,
            coalesce(num_accounts_completed, 0) as NumAccountsCompleted,
            coalesce(num_account_errors, 0) as NumAccountErrors,
            n_subs as NumSubscriptions,
            coalesce(num_subs_completed, 0) as NumSubscriptionsCompleted,
            coalesce(num_sub_errors, 0) as NumSubscriptionErrors,
            n_retries as NumRetries,
            n_templates as NumTemplates,
            n_templates_applied as NumTemplatesApplied
          from
            t_acc_template_session sessions
            inner join
			      VW_HIERARCHYNAME owner on sessions.id_template_owner = owner.id_acc
			      left outer join
			      VW_HIERARCHYNAME submitter on sessions.id_submitter = submitter.id_acc
            left outer join
            (select id_session, count(*) num_accounts_completed, n_retry_count from 
                t_acc_template_session_detail detail 
                inner join 
                t_enum_data type on detail.n_detail_type = type.id_enum_data
                inner join
                t_enum_data status on detail.n_result = status.id_enum_data
                where 
                type.nm_enum_data = 'metratech.com/accounttemplate/DetailType/Update' and
                (status.nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success' or
                 status.nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure')
                group by id_session, n_retry_count) account_total on sessions.id_session = account_total.id_session 
                 and  account_total.n_retry_count = sessions.n_retries
            left outer join
            (select id_session, count(*) num_account_errors, n_retry_count from 
                t_acc_template_session_detail detail 
                inner join 
                t_enum_data type on detail.n_detail_type = type.id_enum_data
                inner join
                t_enum_data status on detail.n_result = status.id_enum_data
                where 
                  type.nm_enum_data = 'metratech.com/accounttemplate/DetailType/Update' and
                  status.nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure'
                group by id_session, n_retry_count) account_errors on sessions.id_session = account_errors.id_session
                 and  account_errors.n_retry_count = sessions.n_retries
            left outer join
            (select id_session, count(*) num_subs_completed, n_retry_count from 
                t_acc_template_session_detail detail 
                inner join 
                t_enum_data type on detail.n_detail_type = type.id_enum_data
                inner join
                t_enum_data status on detail.n_result = status.id_enum_data
                where 
                type.nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription' and
                (status.nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success' or
                 status.nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure')
                group by id_session, n_retry_count) sub_total on sessions.id_session = sub_total.id_session
                 and  sub_total.n_retry_count = sessions.n_retries
            left outer join
            (select id_session, count(*) num_sub_errors, n_retry_count from 
                t_acc_template_session_detail detail 
                inner join 
                t_enum_data type on detail.n_detail_type = type.id_enum_data
                inner join
                t_enum_data status on detail.n_result = status.id_enum_data
                where 
                  type.nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription' and
                  status.nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure'
                group by id_session, n_retry_count) sub_errors on sessions.id_session = sub_errors.id_session
                 and  sub_errors.n_retry_count = sessions.n_retries
        