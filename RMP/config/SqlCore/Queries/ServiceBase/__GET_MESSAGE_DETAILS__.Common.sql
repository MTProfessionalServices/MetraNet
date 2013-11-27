
            select 
              msg.id_message MessageId,
              msg.dt_completed CompletionTime,
              ft.id_failed_transaction FailureId,
              ft.tx_ErrorMessage ErrorMessage, 
              msg.id_pipeline PipelineId              
            from t_message msg %%LOCK%%
            inner join t_session_set ss %%LOCK%% on msg.id_message = ss.id_message
            left outer join t_failed_transaction ft %%LOCK%% on ss.id_ss = ft.id_sch_ss 
            where msg.id_message %%ID_MESSAGE_FILTER%%
        