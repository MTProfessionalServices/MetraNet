
          UPDATE tmp
          /* __UPDATE_BATCHSUB_TEMPLATES_TEMP_TABLE_WITH_TEMPLATE_ID__ */
          /* The next SQL statement is derived from
             Queries/AccHierarchies/SQLServer.xml::__LOAD_ACC_TEMPLATE__

             Get the template id of the closest ancestor to us in the hierarchy that has a template.
             If we have a template then we are the closest ancestor to ourselves in the hierarchy ...
            id_template will remain NULL if we do not have any ancestors in the heirarchy with a template. */
            SET id_template =
                    (
                      SELECT TOP 1 template.id_acc_template
                        FROM t_acc_template template
                          INNER JOIN t_account_ancestor ancestor ON template.id_folder = ancestor.id_ancestor
                          and template.id_acc_type = tmp.id_acc_type
                        WHERE ancestor.id_descendent = tmp.id_ancestor
                          AND tmp.dt_acc_start BETWEEN ancestor.vt_start AND ancestor.vt_end 
      
                        ORDER BY ancestor.num_generations ASC
                    )
            FROM %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
        