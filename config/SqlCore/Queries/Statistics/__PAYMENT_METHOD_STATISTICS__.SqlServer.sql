/* 
   Original SQL replaced with one large query  as follows

*/

select
    concat(reg_instruments.[Payment Method], td.nm_enum_data, reg_instruments.[Card Type], tdx.nm_enum_data, pyi.n_currency) 'Unique Identifier',
	isnull(reg_instruments.[Payment Method], td.nm_enum_data)  'Payment Method'  ,
	isnull( isnull(reg_instruments.[Card Type], tdx.nm_enum_data )  , 'No Card Association' )  'Card Type',
	isnull(pyi.n_currency,  'No Payments Made') 'Payment Currency', 
	isnull( count(pyi.id_acct),0) 'Num of Payments', 
	max(reg_instruments.[Active number useres])  'Registered Users',  
	isnull(min(pyi.n_amount), 0) 'Minimum Payment' , 
	isnull(max(pyi.n_amount),0) 'Maximum Payment', 
	isnull(avg(pyi.n_amount),0 ) 'Average Payment', 
	isnull(max(ptype_last.[Last Transaction Amount]), 0) 'Last transaction of type' ,
	isnull(max(ptype_last.[Last Transaction Date]), 0)   'Last Transaction Date' 
from t_payment_history pyi
left join t_enum_data td on td.id_enum_data = pyi.n_payment_method_type
left outer join t_enum_data tdx on tdx.id_enum_data = pyi.id_creditcard_type
-- following join is required to find the last Transaction of type 
left outer join (select pyl.n_payment_method_type, pyl.id_creditcard_type, pyl.n_currency,
                max(pyl.dt_transaction) 'Last Transaction Date', max(pyl.n_amount) 'Last Transaction Amount'
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
full outer join (
        select edt.nm_enum_data 'Payment Method', edtx.nm_enum_data 'Card Type' , count(*) 'Active number useres'  
                from t_payment_instrument pyi
                left outer join t_enum_data edt on edt.id_enum_data = pyi.n_payment_method_type
                left outer join t_enum_data edtx on edtx.id_enum_data = pyi.id_creditcard_type
                group by edt.nm_enum_data, edtx.nm_enum_data )  reg_instruments
                on reg_instruments.[Payment Method] = td.nm_enum_data AND
                   reg_instruments.[Card Type] = tdx.nm_enum_data 

 
where
 (pyi.dt_transaction between -- start date of the current month and 
	dateadd(mm, datediff(m, 0, DATEADD(m, -8, getdate() )) ,0) 
	AND
	-- end date of the current month
	DATEADD(s, -8, DATEADD(mm, DATEDIFF(m,0, 
	-- start date of the current month 
	dateadd(mm, datediff(m, 0, DATEADD(m, -8, getdate() )) ,0) )  +1
	,0))
) OR pyi.dt_transaction is null
 
group by reg_instruments.[Payment Method],td.nm_enum_data,reg_instruments.[Card Type], tdx.nm_enum_data, pyi.n_currency 
