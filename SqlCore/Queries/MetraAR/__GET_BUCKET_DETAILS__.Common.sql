
                select 
                  dtq.c_DebtTreatmentQueue_Id DTQId,
                  c_Company CompanyName,
                  c_CollectorId CollectorName,
                  c_ExternalAccountId ExternalAccountId,
                  buckets.c_bucket_id BucketId,                  
                  bd.nm_desc BucketDesc,
                  buckets.c_amount Amount,
                  dtq.c_TotalAmountByIC TotalAgingAmountIC,
                  dtq.c_TotalAmountByDC TotalAgingAmountDC
                from 
                t_be_ar_acct_araccount acc
                inner join t_be_ar_acct_debttreatmentq dtq on acc.c_ARAccount_Id = dtq.c_ARAccount_Id
                inner join t_ar_buckets buckets on dtq.c_DebtTreatmentQueue_Id = buckets.c_DebtTreatmentQueue_Id
                inner join t_ar_bucket_def bd on buckets.c_bucket_id = bd.id_bucket_def 
					