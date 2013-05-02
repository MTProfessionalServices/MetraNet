
		UPDATE %%TMP_TABLE_NAME%% tmp
           SET id_template =
                    (
                     select id_acc_template from
                      (
						SELECT template.id_acc_template
                        FROM t_acc_template template
                          INNER JOIN t_account_ancestor ancestor ON template.id_folder = ancestor.id_ancestor
                          inner join %%TMP_TABLE_NAME%% tmp1 on template.id_acc_type = tmp1.id_acc_type
                        WHERE ancestor.id_descendent = tmp1.id_ancestor
                          AND tmp1.dt_acc_start BETWEEN ancestor.vt_start AND ancestor.vt_end     
						ORDER BY ancestor.num_generations ASC
                       )
                      where rownum <= 1
                    )
        