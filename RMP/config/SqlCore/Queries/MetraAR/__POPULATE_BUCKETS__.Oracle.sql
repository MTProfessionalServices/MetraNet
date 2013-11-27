
			
              declare openDFPStatus int;
                      openPDStatus int;
                      bucketSize int;
                      currentDate timestamp;
              
              begin
              
                select id_enum_data into openDFPStatus from t_enum_data where nm_enum_data = 'metratech.com/MetraAR/DFPStatus/Open';
                select id_enum_data into openPDStatus from t_enum_data where nm_enum_data = 'metratech.com/MetraAR/PDStatus/Open';
                currentDate := GETUTCDATE();
              
              
              /* clear out the old data */
              delete from t_ar_buckets;
              update t_be_ar_acct_debttreatmentq set c_TotalAmountByIC = 0.0, c_TotalAmountByDC = 0.0;

              /* seed all the data as 0 amounts*/
              insert into t_ar_buckets
              select id_bucket_def, 0.0, 0.0, c_DebtTreatmentQueue_Id
              from t_ar_bucket_def def
              cross join t_be_ar_acct_debttreatmentq;
            
              /* update the system with relevant aging data */
              
              
              update t_ar_buckets tab  
set 
  (c_bucket_id,c_amount,c_div_amount,c_DebtTreatmentQueue_Id) = 
  (
    select bucket,bucketAmount,bucketDivAmount,dtqId
    FROM  (  
           select bucket, SUM(Amount) bucketAmount, SUM(DivAmount) bucketDivAmount, dtqId
           from (
                select 
                   GetBucketNumber(SYSDATE, dfp.c_DueDate, 0) bucket, 
                  -sum(dfp.c_Amount) Amount, 
                  -SUM(dfp.c_DivAmount) DivAmount,
                  dtq.c_DebtTreatmentQueue_Id dtqId
                from t_be_ar_debt_demandforpayme dfp
                inner join t_be_ar_acct_araccount acc on dfp.c_PayingAcct_Id = acc.c_ARAccount_Id
                inner join t_be_ar_acct_debttreatmentq dtq on acc.c_ARAccount_Id = dtq.c_ARAccount_Id
                where
                  dfp.c_Status <> 1
                group by GetBucketNumber(SYSDATE, dfp.c_DueDate, 0), dtq.c_DebtTreatmentQueue_Id
                union
                select GetBucketNumber(SYSDATE, pd.c_CreationDate, 0), 
                sum(pd.c_Amount), 
                SUM(pd.c_DivAmount),
                dtq.c_DebtTreatmentQueue_Id
                from t_be_ar_pay_paymentdistrib pd
                inner join t_be_ar_acct_araccount acc on pd.c_CurrAcct_Id = acc.c_ARAccount_Id
                inner join t_be_ar_acct_debttreatmentq dtq on acc.c_ARAccount_Id = dtq.c_ARAccount_Id
                where
                  pd.c_Status <> 1
                group by GetBucketNumber(SYSDATE, pd.c_CreationDate, 0),  dtq.c_DebtTreatmentQueue_Id
              ) aging
          group by bucket, dtqId
       ) t
       inner join t_ar_buckets buckets on buckets.c_DebtTreatmentQueue_Id = t.dtqId and buckets.c_bucket_id = t.bucket
    where buckets.c_bucket_id = tab.c_bucket_id and buckets.c_DebtTreatmentQueue_Id = tab.c_DebtTreatmentQueue_Id
  )
 WHERE (c_bucket_id, c_DebtTreatmentQueue_Id) in (
 select bucket,dtqId
    FROM  (  
           select bucket, SUM(Amount) bucketAmount, SUM(DivAmount) bucketDivAmount, dtqId
           from (
                select 
                   GetBucketNumber(SYSDATE, dfp.c_DueDate, 0) bucket, 
                  -sum(dfp.c_Amount) Amount, 
                  -SUM(dfp.c_DivAmount) DivAmount,
                  dtq.c_DebtTreatmentQueue_Id dtqId
                from t_be_ar_debt_demandforpayme dfp
                inner join t_be_ar_acct_araccount acc on dfp.c_PayingAcct_Id = acc.c_ARAccount_Id
                inner join t_be_ar_acct_debttreatmentq dtq on acc.c_ARAccount_Id = dtq.c_ARAccount_Id
                where
                  dfp.c_Status <> 1
                group by GetBucketNumber(SYSDATE, dfp.c_DueDate, 0), dtq.c_DebtTreatmentQueue_Id
                union
                select GetBucketNumber(SYSDATE, pd.c_CreationDate, 0), 
                sum(pd.c_Amount), 
                SUM(pd.c_DivAmount),
                dtq.c_DebtTreatmentQueue_Id
                from t_be_ar_pay_paymentdistrib pd
                inner join t_be_ar_acct_araccount acc on pd.c_CurrAcct_Id = acc.c_ARAccount_Id
                inner join t_be_ar_acct_debttreatmentq dtq on acc.c_ARAccount_Id = dtq.c_ARAccount_Id
                where
                  pd.c_Status <> 1
                group by GetBucketNumber(SYSDATE, pd.c_CreationDate, 0),  dtq.c_DebtTreatmentQueue_Id
              ) aging
          group by bucket, dtqId
       ) t
       inner join t_ar_buckets buckets on buckets.c_DebtTreatmentQueue_Id = t.dtqId and buckets.c_bucket_id = t.bucket
    where buckets.c_bucket_id = tab.c_bucket_id and buckets.c_DebtTreatmentQueue_Id = tab.c_DebtTreatmentQueue_Id
 );

                           
              
           
              update t_be_ar_acct_debttreatmentq D1
                set (D1.c_TotalAmountByIC, 
                D1.c_TotalAmountByDC) = ( SELECT ba.ICAmount, ba.DCAmount FROM (
                                                                                  select SUM(c_amount) ICAmount, 
                                                                                  SUM (c_div_amount) DCAmount,
                                                                                  c_DebtTreatmentQueue_Id dtqId
                                                                                  from t_ar_buckets
                                                                                  group by c_DebtTreatmentQueue_Id
                                                                               ) ba  
                                          WHERE D1.c_debttreatmentqueue_id = ba.dtqId)
              where
              EXISTS (SELECT ba.ICAmount, ba.DCAmount FROM (
                  select SUM(c_amount) ICAmount, 
                        SUM (c_div_amount) DCAmount,
                        c_DebtTreatmentQueue_Id dtqId
                  from t_ar_buckets
                 group by c_DebtTreatmentQueue_Id
              ) ba 
                         where d1.c_debttreatmentqueue_id = ba.dtqId);
           
              end;
					