
        /* Summary by interval type */
        select
            RAWTOHEX(SYS_GUID()) as UniqueId,
            uc.id_cycle_type as UsageCycleType,
            CASE WHEN uc.id_cycle_type IS NULL THEN N'UNDETERMINED' ELSE MAX(uct.tx_desc) END as UsageCycleTypeName,
            (CASE uc.id_cycle_type
                WHEN 1 THEN CAST(uc.day_of_month AS varchar(5)) /*Monthly*/
                WHEN 3 THEN '' /*Daily*/
                WHEN 4 THEN CAST(uc.start_day AS varchar(5))  /*Weekly*/
                WHEN 5 THEN CAST(uc.start_day AS varchar(5)) || ' ' || CAST(uc.start_month AS varchar(5)) /*Bi-weekly*/
                WHEN 6 THEN CAST(uc.first_day_of_month AS varchar(5)) || ' ' || CAST(uc.second_day_of_month AS varchar(5)) /*Semi-monthly*/
                WHEN 7 THEN CAST(uc.start_day AS varchar(5)) || ' ' || CAST(uc.start_month AS varchar(5)) /*Quaterly*/
                WHEN 8 THEN CAST(uc.start_day AS varchar(5)) || ' ' || CAST(uc.start_month AS varchar(5))/*Annually*/
                ELSE '' END) as UsageCycleValue,
            COUNT(*) as Count
        from 
          t_failed_transaction ft
        left join t_acc_usage_cycle auc on auc.id_acc = ft.id_PossiblePayerID
        left join t_usage_cycle uc on auc.id_usage_cycle = uc.id_usage_cycle
        left join t_usage_cycle_type uct on uc.id_cycle_type = uct.id_cycle_type
        where 
          State in ('N','I', 'C') and  (
                                         (dt_start_resubmit IS NULL)
                                          OR 
                                         (dt_start_resubmit < TO_TIMESTAMP ('%%DiffTime%%','MM/dd/yyyy hh24:mi:ss.ff'))
                                        ) 
        group by uc.id_cycle_type, uc.day_of_month, uc.start_day, uc.start_month, uc.first_day_of_month, second_day_of_month
        order by Count desc
            