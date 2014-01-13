
                CREATE TABLE [t_ar_buckets]
                (
                  [c_bucket_id] [int] NOT NULL,
                  [c_amount] [decimal](22,10) NOT NULL,
                  [c_div_amount] [decimal](22,10) NOT NULL,
                  [c_DebtTreatmentQueue_Id] [uniqueidentifier] NOT NULL
                ) ON [PRIMARY]
				