
-- select Credit or PaymentReceipt for a given dfp id, invoice as a parent
/*__GET_DFP_ALLOCATION_FOR_INVOICE__*/
select 
  pd.c_Credit_Id,
  pd.c_PaymentReceipt_Id
from t_be_ar_debt_demandforpayme dfp
  inner join t_be_ar_all_paymtdistalloc pda on pda.c_DemandForPayment_Id = dfp.c_DemandForPayment_Id
      and @snapshot >= pda.c_StartDate and @snapshot < pda.c_EndDate
  inner join t_be_ar_pay_paymentdistrib pd on pd.c_PaymentDistribution_Id = pda.c_PaymentDistribution_Id
where 
  dfp.c_DemandForPayment_Id = @id
      