
				select 
				  dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/
                  COALESCE(partition_name, N'Non-Partitioned') "PARTITION",
				  count(*) "Number of NRCs Generated",
				  case c_NRCEventType 
				    when 0 then 'Unknown' 
				    when 1 then 'SUBSCRIPTION'
				    when 2 then 'UNSUBSCRIPTION' 
				    when 3 then 'Change-Subscription' 
				    end "Reason for Generation", 
				  am_currency "Currency",
				  SUM({fn ifnull(au.Amount, 0.0)}) "Amount"
				from t_acc_usage au
				inner join t_pv_nonrecurringcharge nrc 
				  on au.id_sess=nrc.id_sess
				  and au.id_usage_interval = nrc.id_usage_interval
				inner join t_vw_base_props bp on au.id_pi_template=bp.id_prop
                left outer join vw_bus_partition_accounts bpt on bpt.id_acc = au.id_acc
				where au.id_usage_interval like '%%ID_INTERVAL%%'
				  and id_lang_code like '%%ID_LANG_CODE%%'
				group by partition_name,
	        case c_NRCEventType 
				    when 0 then 'Unknown' 
				    when 1 then 'SUBSCRIPTION'
				    when 2 then 'UNSUBSCRIPTION' 
				    when 3 then 'Change-Subscription' end,
				  am_currency
