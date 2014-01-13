
					CREATE TABLE [dbo].[t_ar_gl_batch](
					[c_BatchId][int]NOT NULL 
					,[c_CreateDate][datetime]NOT NULL
					,[c_StatusDate][datetime]
					,[c_BatchStatus][int]NOT NULL  /*e.g. HardClosed*/
					,[c_BatchType][int]NOT NULL    /*e.g. Payment*/
					,[c_Currency][int]NOT NULL
					,[c_DivisionCurrency][int]NOT NULL
					,[c_DivisionAmountTotal][decimal](22,10) CONSTRAINT df_DivisionTotalAmount DEFAULT 0
					,[c_ExchangeRate][decimal](22,10) CONSTRAINT df_ExchangeRate DEFAULT 1
					,[c_TotalAmount][decimal](22,10) CONSTRAINT df_TotalAmount DEFAULT 0
					,[c_GainLossAmount][decimal](22,10)
					,[c_DomainId][uniqueidentifier]NOT NULL
					,[c_BatchTransactionType][int]NOT NULL  /*e.g. PaymentReceiptType.Check*/
					,[c_IntendedDate][datetime]         /*?*/
					, CONSTRAINT PK_t_ar_matching_batch_BatchId PRIMARY KEY (c_BatchId)
				/*	, CONSTRAINT FK_t_ar_matching_batch FOREIGN KEY (c_DomainId) REFERENCES t_be_ar_dom_domain (c_Domain_Id) */
					)
					