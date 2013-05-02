
          SELECT id_acc
          FROM %%TMP_TABLE_NAME%% WITH(READCOMMITTED)
          WHERE id_template IS NULL
        