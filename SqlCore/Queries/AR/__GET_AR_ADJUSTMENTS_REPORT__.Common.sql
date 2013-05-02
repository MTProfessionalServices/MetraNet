
          SELECT
            au.id_sess as id_sess,
            au.amount as amount,
            au.am_currency as "currency",
            pv.c_Description as "description",
            pv.c_EventDate as event_date,
            rcdescr.tx_desc as reason_code
          FROM
            t_pv_ARAdjustment pv
            JOIN t_acc_usage au on au.id_sess = pv.id_sess
            and au.id_usage_interval = pv.id_usage_interval
            INNER JOIN t_prod_view prv on au.id_view = prv.id_view AND prv.nm_table_name in ('t_pv_ARAdjustment')
            LEFT OUTER JOIN t_description rcdescr ON pv.c_ReasonCode = rcdescr.id_desc
              AND rcdescr.id_lang_code = %%ID_LANG_CODE%%
          WHERE
            au.id_acc = %%ID_ACC%%
            AND au.id_usage_interval = %%ID_INTERVAL%%
          ORDER BY pv.c_EventDate
        