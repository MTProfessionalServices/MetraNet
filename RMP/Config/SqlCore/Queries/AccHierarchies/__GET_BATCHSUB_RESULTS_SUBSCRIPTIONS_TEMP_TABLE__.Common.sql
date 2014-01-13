
          /* The next SQL statement is derived from
             Queries/AccHierarchies/CommonQueries.xml::__LOAD_TEMPLATE_SUBSCRIPTIONS__
             Now populate the tmp_batchsub_subscriptions table with all of the subscriptions
             that need to be updated based on the templates that we found in the earlier steps.
             Note that for each row in the tmp_batchsub_templates table multiple rows may be
             inserted into the tmp_batchsub_subscriptions table (i.e. a template may have
             multiple subscriptions associated with it). */
           
            SELECT
            tmp.id_acc as id_acc, 
            tmp.id_corporate as id_corporate, 
            tmp.dt_acc_start as dt_acc_start,
            tmp.dt_acc_end as dt_acc_end,
            CASE WHEN (tsubs.id_group IS NULL) THEN tsubs.id_po ELSE sub.id_po END AS id_po,
            tsubs.id_group AS id_group_sub,
            sub.id_sub as id_sub, 
            sub.vt_start as dt_sub_start,
            sub.vt_end as dt_sub_end
            FROM t_acc_template_subs tsubs
            INNER JOIN %%TMP_TABLE_NAME%% tmp %%%READCOMMITTED%%%
                                               ON tsubs.id_acc_template = tmp.id_template
            LEFT OUTER JOIN t_group_sub gsub ON tsubs.id_group = gsub.id_group
            LEFT OUTER JOIN t_sub sub ON sub.id_group = gsub.id_group
        