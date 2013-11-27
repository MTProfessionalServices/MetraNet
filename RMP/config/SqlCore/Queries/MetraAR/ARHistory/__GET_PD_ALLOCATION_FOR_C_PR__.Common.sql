
-- select Statement, OPR or CreditReversal for a given pd id, credit or payment receipt as a parent
/*__GET_PD_ALLOCATION_FOR_C_PR__*/
select
  i.c_ARStatement_Id,
  pda.c_CreditReversal_Id,
  pda.c_OutgoingPaymentRequest_Id
from 
  t_be_ar_pay_paymentdistrib pd
  inner join t_be_ar_all_paymtdistalloc pda on pda.c_PaymentDistribution_Id = pd.c_PaymentDistribution_Id
      and @snapshot >= pda.c_StartDate and @snapshot < pda.c_EndDate
  left outer join t_be_ar_debt_demandforpayme dfp on dfp.c_DemandForPayment_Id = pda.c_DemandForPayment_Id
  left outer join t_be_ar_debt_arinvoice i on dfp.c_ARInvoice_Id = i.c_ARInvoice_Id
where
  pd.c_PaymentDistribution_Id = @id
      