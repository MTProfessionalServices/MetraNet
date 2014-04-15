select COUNT(*) as Count_Over_Set_Days from t_failed_transaction ft where  
ft.dt_FailureTime < DATEADD(day, -(%%AGE_THRESHOLD%%), GetDate())
and State = 'N';
