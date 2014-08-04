
/*__PAYMENT_METHOD_STATISTICS_ */
select
   concat(concat (concat(reg_instruments.PaymentMethod, td.nm_enum_data), tdx.nm_enum_data), pyi.n_currency) "Unique Identifier",
	NVL(reg_instruments.PaymentMethod, td.nm_enum_data)  "Payment Method"  ,
	
  NVL(coalesce(reg_instruments.CardType, tdx.nm_enum_data ), 'No Card Association') "Card Type" ,
	NVL(pyi.n_currency,'NoPaymentsMade') "Payment Currency", 
	NVL( count(pyi.id_acct),0) "Num of Payments", 
	max(reg_instruments.Activenumberuseres)  "Registered Users",  
	NVL(min(pyi.n_amount), 0) "Minimum Payment" , 
	NVL(max(pyi.n_amount),0) "Maximum Payment", 
	NVL(avg(pyi.n_amount),0 ) "Average Payment", 
	NVL(max(ptype_last.LastTransactionAmount), 0) "Last transaction of type" ,
	NVL(max(ptype_last.LastTransactionDate), 0)   "Last Transaction Date" 
from t_payment_history pyi

left join t_enum_data td on td.id_enum_data = pyi.n_payment_method_type
	
left outer join t_enum_data tdx on tdx.id_enum_data = pyi.id_creditcard_type
-- following join is required to find the last Transaction of type 
left outer join
(select
      pyl.n_payment_method_type, 
      pyl.id_creditcard_type, 
      pyl.n_currency,
      TO_CHAR(max(pyl.dt_transaction)) LastTransactionDate, 
      max(pyl.n_amount) LastTransactionAmount
      from t_payment_history pyl 
                left outer join t_payment_history pyx 
                   on  pyl.n_payment_method_type = pyx.n_payment_method_type 
                   and
                        pyl.n_currency = pyx.n_currency
                   and  pyl.dt_last_updated < pyx.dt_last_updated
       
      where pyx.n_payment_method_type is null   
      group by pyl.n_payment_method_type, pyl.id_creditcard_type, pyl.n_currency   ) ptype_last
on 
  ptype_last.n_payment_method_type = pyi.n_payment_method_type
  AND ptype_last.n_currency = pyi.n_currency
full outer join (

        select 
              edt.nm_enum_data PaymentMethod, 
              edtx.nm_enum_data CardType , 
              count(*) Activenumberuseres 
                from t_payment_instrument pyi
                left outer join t_enum_data edt on edt.id_enum_data = pyi.n_payment_method_type
                left outer join t_enum_data edtx on edtx.id_enum_data = pyi.id_creditcard_type
                group by edt.nm_enum_data, edtx.nm_enum_data )
                reg_instruments
                on reg_instruments.PaymentMethod = td.nm_enum_data 
                AND
                   reg_instruments.CardType = tdx.nm_enum_data 
                   where
                   
                  (pyi.dt_transaction between TO_CHAR (trunc(trunc(sysdate,'MM')-8,'MM'), 'MM-DD-YYYY HH24:MI:SS')  AND
            TO_CHAR (trunc(sysdate,'MM')-8, 'MM-DD-YYYY HH24:MI:SS')
            ) OR (pyi.dt_transaction is null)

          group by reg_instruments.PaymentMethod,td.nm_enum_data,reg_instruments.CardType, tdx.nm_enum_data, pyi.n_currency


 

 