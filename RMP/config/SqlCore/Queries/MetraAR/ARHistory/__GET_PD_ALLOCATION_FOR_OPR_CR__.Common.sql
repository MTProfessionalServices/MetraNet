
-- select Credit or PaymentReceipt for a given pd id, ORP or CR as a parent
/*__GET_PD_ALLOCATION_FOR_OPR_CR__*/
select
  pd.c_Credit_Id,
  pd.c_PaymentReceipt_Id
from 
  t_be_ar_pay_paymentdistrib pd
  --this join we only need to check that allocation was valid for @snapshot date
  inner join t_be_ar_all_paymtdistalloc pda on pda.c_PaymentDistribution_Id = pd.c_PaymentDistribution_Id
      and @snapshot >= pda.c_StartDate and @snapshot < pda.c_EndDate
where
  pd.c_PaymentDistribution_Id = @id
      