
select 
/* __GET_ADJUSTMENT_DETAIL_DATAMART__ */
au.id_view ViewID, 
au.id_sess SessionID, 
au.amount Amount,
au.am_currency Currency, 
au.id_acc AccountID, 
/* TODO: place this logic in the vw_mps_acc_mapper view */
map.displayname DisplayName,
au.dt_session Timestamp, 
au.id_pi_template PITemplate,
au.id_pi_instance PIInstance,
'%%SESSION_TYPE%%' SessionType,
/* %%AJ_TABLE_NAME%% */
({fn IFNULL(au.tax_federal, 0.0)} + {fn IFNULL(au.tax_state, 0.0)} + {fn IFNULL(au.tax_county, 0.0)} + 
        {fn IFNULL(au.tax_local, 0.0)} + {fn IFNULL(au.tax_other, 0.0)}) TaxAmount, 
(au.amount + 
        {fn IFNULL(au.tax_federal, 0.0)} + {fn IFNULL(au.tax_state, 0.0)} + {fn IFNULL(au.tax_county, 0.0)} + 
        {fn IFNULL(au.tax_local, 0.0)} + {fn IFNULL(au.tax_other, 0.0)}) AmountWithTax, 
au.id_usage_interval IntervalID
,ajdetails.IsPrebill IsPrebillTransaction
,ajdetails.IsPrebillAdjusted
,ajdetails.IsPostbillAdjusted
%%SELECT_CLAUSE%%
from 
%%TABLE_NAME%% pv, 
vw_mps_acc_mapper map
%%FROM_CLAUSE%%
,t_acc_usage au
,vw_adjustment_details_datamart ajdetails
where 
%%ACCOUNT_PREDICATE%% 
and 
%%TIME_PREDICATE%% 
and 
au.id_sess = pv.id_sess 
and au.id_usage_interval=pv.id_usage_interval
and 
%%SESSION_PREDICATE%% 
and 
%%PRODUCT_PREDICATE%% 
and 
au.id_payee=map.id_acc
and 
au.id_sess= ajdetails.id_sess

%%WHERE_CLAUSE%% %%EXT%%
			 