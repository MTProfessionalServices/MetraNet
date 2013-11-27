
                    CREATE TABLE t_ar_gl_batch (
                    c_BatchId NUMBER(10) NOT NULL 
                    ,c_CreateDate timestamp NOT NULL
                    ,c_StatusDate timestamp 
                    ,c_BatchStatus NUMBER(10) NOT NULL 
                    ,c_BatchType NUMBER(10) NOT NULL 
                    ,c_Currency NUMBER(10) NOT NULL
                    ,c_DivisionCurrency NUMBER(10) NOT NULL
                    ,c_DivisionAmountTotal NUMBER(22,10) DEFAULT 0
                    ,c_ExchangeRate NUMBER (22,10) DEFAULT 1
                    ,c_TotalAmount NUMBER (22,10) DEFAULT 0
                    ,c_GainLossAmount NUMBER (22,10)
                    ,c_DomainId RAW(16) NOT NULL
                    ,c_BatchTransactionType NUMBER(10) NOT NULL 
                    ,c_IntendedDate timestamp          
                    ,CONSTRAINT PK_t_ar_glbch PRIMARY KEY (c_BatchId)
                    )
					