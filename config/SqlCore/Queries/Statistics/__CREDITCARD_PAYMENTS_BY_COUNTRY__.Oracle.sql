select  
      NVL(pti.id_country, '*********' ) id_country, 
       NVL(tdx.nm_enum_data,  tdxi.nm_enum_data)  "CardType",
       NVL(pyi.n_currency , '***') n_currency,
	   count(pti.id_creditcard_type) "Registeredusers", 
	   count(pyi.id_creditcard_type) "NumofPayments", 
	   NVL(min(pyi.n_amount), 0) "Minimum Amount" , 
	   NVL(max(pyi.n_amount), 0) "Maximum Amount", 
	   NVL(avg(pyi.n_amount), 0) "Average Amount", 
	  NVL(max(ptype_last.LastTranactionAmount), 0) LastTrasactionofType ,
	  NVL(max(ptype_last.LastTrasactionDate), 0)  LastTrasactionDate,
	   NVL(td.nm_enum_data, tdi.nm_enum_data)  "PaymentType"
from 
   t_payment_history pyi
full outer join 
				(select ptt.id_payment_instrument, ptt.n_payment_method_type, ptt.id_creditcard_type, 
						 ett.nm_enum_data id_country 
				    from  t_payment_instrument ptt
				   inner join t_enum_data ett on ett.id_enum_data = ptt.id_country) pti 
           on pti.id_payment_instrument = pyi.id_payment_instrument

left join t_enum_data td on td.id_enum_data = pyi.n_payment_method_type
left join t_enum_data tdi on tdi.id_enum_data = pti.n_payment_method_type
left  join t_enum_data tdx on tdx.id_enum_data = pyi.id_creditcard_type
left  join t_enum_data tdxi on tdxi.id_enum_data = pti.id_creditcard_type
left outer join 
(select pyl.n_payment_method_type, pyl.id_creditcard_type, pyl.n_currency,
                to_char (max(pyl.dt_transaction)) LastTrasactionDate, max(pyl.n_amount) LastTranactionAmount
                from t_payment_history pyl 
                left outer join t_payment_history pyx 
                   on ( pyl.n_payment_method_type = pyx.n_payment_method_type and
                        pyl.n_currency = pyx.n_currency
                         and  pyl.dt_last_updated < pyx.dt_last_updated
                          )
                 where pyx.n_payment_method_type is null   
                 group by pyl.n_payment_method_type, pyl.id_creditcard_type, pyl.n_currency   ) ptype_last
on 
  ptype_last.n_payment_method_type = pyi.n_payment_method_type
  AND ptype_last.n_currency = pyi.n_currency
where 
  (pyi.dt_transaction between  TO_CHAR (trunc(trunc(sysdate,'MM')-1,'MM'), 'MM-DD-YYYY HH24:MI:SS')  AND
TO_CHAR  (trunc(sysdate,'MM')-1, 'MM-DD-YYYY HH24:MI:SS'))
  
            OR (pyi.dt_transaction is null) AND ( tdx.nm_enum_data is not null  OR tdxi.nm_enum_data is not null )

group by pti.id_country , td.nm_enum_data, tdi.nm_enum_data, tdx.nm_enum_data, tdxi.nm_enum_data, pyi.n_currency 
