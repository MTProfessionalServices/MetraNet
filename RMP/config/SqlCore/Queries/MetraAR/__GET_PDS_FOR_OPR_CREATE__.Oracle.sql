
       begin

       open :result0 for
				select 
				acc.c_ARAccount_Id         AccountId
				,acc.c_ExternalAccountId   ExternalId
				,acc.c__version			   AccountVersion
				,domain.c_Domain_Id        DomainId
				,domain.c_Name             DomainName
				,domain.c__version         DomainVersion
				from t_be_ar_acct_araccount acc
				inner join t_be_ar_dom_domain domain 
				 on acc.c_Domain_Id = domain.c_Domain_Id
				 where acc.c_ExternalAccountId = :acctId;

       open :result1 for
				select pd.c_PaymentDistribution_Id
					 , pd.c__version      PD_Version
					 , pd.c_internal_key  InternalKey        
					 , pd.c_CreationDate  CreationDate
					 , pd.c_UpdateDate    UpdateDate
					 , pd.c_Status        PD_Status
					 , pd.c_IntendedDate  IntendedDate
					 , pd.c_Amount        PD_Amount
					 , pd.c_Currency      Currency
					 , pd.c_Description   PD_Description
					 , pd.c_DivAmount     PD_DivisionAmount
					 , pd.c_CurrAcct_Id  CurrentAccountId
					 , pd.c_OrigAcct_Id OriginalAccontId
					 , pd.c_OriginType        OriginType
					 , pd.c_DivCurrency       DivisionCurrency
					 , pd.c_RootId             RootId
					 , acc.c_ExternalAccountId ARAccount
					 , mgr.c_ExternalAccountId MgrAccount
					 , mgr.c_ARAccount_Id      MgrAccountId
					 , domain.c_Name          Domain
					 , domain.c_Domain_Id     DomainId
					 , pr.c_PaymentReceipt_Id PaymentReceipt
					 , pr.c__version          PaymentVersion
					 , pr.c_ExternalId      PaymentExternalId
					 , pr.c_PaymentType       PaymentType
					 , pr.c_PaymentInstrumentId PaymentInstrumentId
					 , pr.c_CcType              CreditCardType
					 , pr.c_Amount              PaymentReceiptAmount
					 , pr.c_DivAmount           PaymentReceiptDivAmount
					 , cr.c_Credit_Id           CreditId
					 , cr.c_DisputeId           DisputeId
					 , cr.c__version            CreditVersion
					 , cr.c_CreditReasonCode    CreditReasonCode
					 , cr.c_Amount              CreditAmount
					 , cr.c_DivisionAmount      CreditDivAmount
				 from t_be_ar_pay_paymentdistrib pd
				 inner join t_be_ar_acct_araccount acc
				    on acc.c_ARAccount_Id = pd.c_CurrentAccountId
				 left outer join t_be_ar_acct_araccount mgr
				    on acc.c_ManagedBy_Id = mgr.c_ARAccount_Id
				 inner join t_be_ar_dom_domain domain
				    on domain.c_Domain_Id = pd.c_Domain_Id
				 left outer join t_be_ar_pay_paymentreceipt pr 
					on pd.c_PaymentReceipt_Id = pr.c_PaymentReceipt_Id
				 left outer join t_be_ar_pay_credit cr
					on pd.c_Credit_Id = cr.c_Credit_Id
                %%_WHERE_CLAUSE_%% ;

                end;
					