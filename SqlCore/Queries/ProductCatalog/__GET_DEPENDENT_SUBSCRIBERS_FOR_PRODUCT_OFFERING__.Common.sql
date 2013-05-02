
select   /* __GET_DEPENDENT_SUBSCRIBERS_FOR_PRODUCT_OFFERING__ */
	sub.id_group as id,
	case
	   when sub.id_group is not null 
		 then 'Group Subscription: ' %%%CONCAT%%% gsub.tx_name
	   else N'Non-Group Subscriptions'
	end as name,
	count(sub.id_acc) as count, min(vt_start) as minstart,
	max(vt_end) as maxend
from t_vw_expanded_sub sub 
inner join t_account_mapper amap 
	on sub.id_acc = amap.id_acc
inner join t_namespace ns 
	on ns.nm_space = amap.nm_space
   and lower(ns.tx_typ_space) in ('system_mps', 'system_user', 'system_auth')
inner join t_enum_data ed 
 	on %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%('metratech.com/accountcreation/contacttype/bill-to')
left outer join t_group_sub gsub 
	on sub.id_group = gsub.id_group
where id_po = %%ID_PO%%
group by sub.id_group, gsub.tx_name
  