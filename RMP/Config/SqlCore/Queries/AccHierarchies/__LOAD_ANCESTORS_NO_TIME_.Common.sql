
        select id_ancestor,
        case when parent_map.nm_login is NULL then N'Root' else parent_map.nm_login end as parent,
        id_descendent,child_map.nm_login account,
        num_generations,b_children,vt_start,vt_end,tx_path
        from t_account_ancestor 
        LEFT OUTER JOIN vw_mps_acc_mapper parent_map on parent_map.id_acc = id_ancestor
        INNER JOIN vw_mps_acc_mapper child_map on child_map.id_acc = id_descendent
        where id_descendent = %%ACC_ID%%
        order by vt_start,vt_end,num_generations asc
					