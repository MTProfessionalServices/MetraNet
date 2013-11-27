
              declare @openDFPStatus int
              declare @openPDStatus int
              declare @bucketSize int
              declare @currentDate datetime

              set @openDFPStatus = (select id_enum_data from t_enum_data where nm_enum_data = 'metratech.com/MetraAR/DFPStatus/Open')
              set @openPDStatus =  (select id_enum_data from t_enum_data where nm_enum_data = 'metratech.com/MetraAR/PDStatus/Open')
              set @currentDate = GETUTCDATE()

              /* clear out the old data */
              delete from t_ar_buckets
              update t_be_ar_acct_debttreatmentq set c_TotalAmountByIC = 0.0, c_TotalAmountByDC = 0.0

              /* seed all the data as 0 amounts*/
              insert into t_ar_buckets
              select id_bucket_def, 0.0, 0.0, c_DebtTreatmentQueue_Id
              from t_ar_bucket_def def
              cross join t_be_ar_acct_debttreatmentq

              /* update the system with relevant aging data */
              update t_ar_buckets   
              set
                c_bucket_id = bucket, 
                c_amount = bucketAmount,
                c_div_amount = bucketDivAmount,
                c_DebtTreatmentQueue_Id = dtqId 
              FROM 
              (  
              select bucket, SUM(Amount) bucketAmount, SUM(DivAmount) bucketDivAmount, dtqId
              from (
                select 
                   dbo.GetBucketNumber(@currentDate, dfp.c_DueDate, 0) bucket, 
                  -sum(dfp.c_Amount) Amount, 
                  -SUM(dfp.c_DivAmount) DivAmount,
                  dtq.c_DebtTreatmentQueue_Id dtqId
                from t_be_ar_debt_demandforpayme dfp
                inner join t_be_ar_acct_araccount acc on dfp.c_PayingAcct_Id = acc.c_ARAccount_Id
                inner join t_be_ar_acct_debttreatmentq dtq on acc.c_ARAccount_Id = dtq.c_ARAccount_Id
                where
                  dfp.c_Status <> 1
                group by dbo.GetBucketNumber(@currentDate, dfp.c_DueDate, 0), dtq.c_DebtTreatmentQueue_Id
                union
                select dbo.GetBucketNumber(@currentDate, pd.c_CreationDate, 0), 
                sum(pd.c_Amount), 
                SUM(pd.c_DivAmount),
                dtq.c_DebtTreatmentQueue_Id
                from t_be_ar_pay_paymentdistrib pd
                inner join t_be_ar_acct_araccount acc on pd.c_CurrAcct_Id = acc.c_ARAccount_Id
                inner join t_be_ar_acct_debttreatmentq dtq on acc.c_ARAccount_Id = dtq.c_ARAccount_Id
                where
                  pd.c_Status <> 1
                group by dbo.GetBucketNumber(@currentDate, pd.c_CreationDate, 0),  dtq.c_DebtTreatmentQueue_Id
              ) aging
              group by bucket, dtqId
              ) t
              inner join t_ar_buckets buckets on buckets.c_DebtTreatmentQueue_Id = t.dtqId and buckets.c_bucket_id = t.bucket

              update t_be_ar_acct_debttreatmentq 
                set c_TotalAmountByIC = ICAmount, 
                c_TotalAmountByDC = DCAmount
              FROM
              (
              select SUM(c_amount) ICAmount, 
                   SUM (c_div_amount) DCAmount,
                   c_DebtTreatmentQueue_Id dtqId
                   from t_ar_buckets
              group by c_DebtTreatmentQueue_Id) bucketAmt
              inner join t_be_ar_acct_debttreatmentq q on q.c_DebtTreatmentQueue_Id = bucketAmt.dtqId
					