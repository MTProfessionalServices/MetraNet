select COUNT(*) as Count_Over_Set_Days from t_failed_transaction ft where  
ft.dt_FailureTime < GETUTCDATE()-%%AGE_THRESHOLD%%
and State in ('N', 'I')
