select id_acc_template
        ,id_folder
        ,dt_crt
        ,tx_name
        , tx_desc
        , nm_login
        , nm_space
        , b_ApplyDefaultPolicy
    from (
        select id_acc_template
                ,id_folder
                ,dt_crt
                ,tx_name
                , tx_desc
                , nm_login
                , nm_space
                , case when id_folder = %%ACCOUNTID%% then b_ApplyDefaultPolicy else 'N' end as b_ApplyDefaultPolicy
            from t_acc_template template
            INNER JOIN t_account_ancestor ancestor on template.id_folder = ancestor.id_ancestor
            INNER JOIN t_account_mapper mapper on mapper.id_acc = ancestor.id_ancestor
            LEFT JOIN t_acc_tmpl_types tatp on 1 = 1
            WHERE id_descendent = %%ACCOUNTID%% 
                AND %%REFDATE%% between vt_start AND vt_end 
                AND (id_acc_type = %%ACCOUNTTYPEID%% OR NVL(tatp.all_types,0) = 1)
            ORDER BY num_generations asc
    )
    where rownum = 1
