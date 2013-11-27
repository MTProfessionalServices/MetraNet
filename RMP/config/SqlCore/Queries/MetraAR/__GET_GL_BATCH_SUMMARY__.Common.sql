    
        SELECT 
 			c_BatchId BatchId
			,c_CreateDate CreateDate
			,c_StatusDate StatusDate
			,c_BatchStatus BatchStatus
			,c_BatchType BatchType
			,gl.c_Currency Currency
			,c_DivisionCurrency DivisionCurrency
			,c_DivisionAmountTotal DivisionAmountTotal
			,c_ExchangeRate ExchangeRate
			,c_TotalAmount TotalAmount
			,c_GainLossAmount GainLossAmount
			,dom.c_Name Domain
			,c_BatchTransactionType BatchTransactionType
			,c_IntendedDate IntendedDate
		FROM
			t_ar_gl_batch gl
			inner join t_be_ar_dom_domain dom
			  on gl.c_DomainId = dom.c_Domain_Id
        