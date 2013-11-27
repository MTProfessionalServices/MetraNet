
          INSERT INTO %%TMP_TABLE_NAME%%
          (
              id_acc,
              id_ancestor,
              id_corporate,
              dt_acc_start,
              dt_acc_end,
              id_acc_type
          )
          VALUES
          (
            ?, ?, ?, ?, ?, ?
          )
        