
/* making everything int to a big large select due to our query manager incapabilities 
declare @date_start_of_month datetime
declare @date_end_of_month datetime
-- obtain the start and end dates of the past motth. (by changing the start date below various payment information can be obtained )
 set @date_start_of_month = dateadd(mm, datediff(m, 0, DATEADD(m, -1, getdate() )) ,0) 
  set @date_end_of_month = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@date_start_of_month)+1,0)) 
*/
/*
just test what the out put looks like
select @date_start_of_month, @date_end_of_month
SELECT * 
FROM t_payment_history where dt_transaction between @date_start_of_month AND @date_end_of_month
*/
 
/* temp object removed as our query manager cannot handle temp objects
  if OBJECT_ID('tempdb..#payment_history_summary') is not null drop table #payment_history_summary
*/

 
select 
	   dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/
	   isnull(pti.id_country, '*********' ) id_country, 
       isnull(tdx.nm_enum_data,  tdxi.nm_enum_data)  'Card Type',
       isnull(pyi.n_currency , '***') n_currency,
	   count(pti.id_creditcard_type) 'Registered users', 
	   count(pyi.id_creditcard_type) 'Num of Payments', 
	   isnull(min(pyi.n_amount), 0) 'Minimum Amount' , 
	   isnull(max(pyi.n_amount), 0) 'Maximum Amount', 
	   isnull(avg(pyi.n_amount), 0) 'Average Amount', 
	   isnull(max(ptype_last.[Last Tranaction Amount]), 0) 'Last transaction of type' ,
	   isnull(max(ptype_last.[Last Trasaction Date]), 0)  'Last Trasaction Date',
	   isnull(td.nm_enum_data, tdi.nm_enum_data)  'Payment Type'
/* commented due to the query mangers inablity to support variables and temp tables
 -- into #payment_history_summary
*/

from 
   t_payment_history pyi
full outer join 
				(select ptt.id_payment_instrument, ptt.n_payment_method_type, ptt.id_creditcard_type, 
						 ett.nm_enum_data id_country 
				    from  t_payment_instrument ptt
				   inner join t_enum_data ett on ett.id_enum_data = ptt.id_country
                       ) pti on pti.id_payment_instrument = pyi.id_payment_instrument

left join t_enum_data td on td.id_enum_data = pyi.n_payment_method_type
left join t_enum_data tdi on tdi.id_enum_data = pti.n_payment_method_type
left  join t_enum_data tdx on tdx.id_enum_data = pyi.id_creditcard_type
left  join t_enum_data tdxi on tdxi.id_enum_data = pti.id_creditcard_type
-- following join is required to find the last tranaction of type 
left outer join (select pyl.n_payment_method_type, pyl.id_creditcard_type, pyl.n_currency,
                max(pyl.dt_transaction) 'Last Trasaction Date', max(pyl.n_amount) 'Last Tranaction Amount'
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
 (pyi.dt_transaction between dateadd(mm, datediff(m, 0, DATEADD(m, -1, getdate() )) ,0)  AND 
						     DATEADD(s,-1,DATEADD(mm, DATEDIFF(m, 0, 
									 dateadd(mm, datediff(m, 0, DATEADD(m, -1, getdate() )) ,0)
									)+1,0))
  
            OR pyi.dt_transaction is null) AND ( tdx.nm_enum_data is not null  OR tdxi.nm_enum_data is not null )

group by pti.id_country , td.nm_enum_data, tdi.nm_enum_data, tdx.nm_enum_data, tdxi.nm_enum_data, pyi.n_currency 
 
/*  Link up the above payment history records for the given month agains the number of registered 
*   system payment instruments. There may be descrepencies Hence the joins separately
*/

-- select id_creditcard_type, id_country from t_payment_instrument group by id_creditcard_type, id_country
-- select * from #payment_history_summary

/*
 
select   isnull(edty.nm_enum_data, 'Unregistered Payment Country') 'Country' , 
         pmt_info.[Related Type]  'Card Type',  
		 pmt_info.[Registered users], 
       isnull(pmt_info.[Num of Payments], 0)  'Number of Payments',
       isnull(pmt_info.[n_currency], 'No Payments')  'Payments Currency',
       isnull(pmt_info.[Minimum Amount], 0) 'Minimum Payment',
       isnull(pmt_info.[Maximum Amount], 0) 'Maximum Amount',
       isnull(pmt_info.[Average Amount], 0) 'Average Amount',
       isnull(pmt_info.[Last transaction of type], 0) 'Last transaction', 
       isnull(pmt_info.[Last Trasaction Date] , 0) 'Last Transaction Date', 
	   pmt_info.[Payment Type] 'Payment Method'

 from #payment_history_summary pmt_info

     	left outer join t_enum_data edty on edty.id_enum_data = pmt_info.id_country
     

     where pmt_info.[Related Type] is not null 

*/