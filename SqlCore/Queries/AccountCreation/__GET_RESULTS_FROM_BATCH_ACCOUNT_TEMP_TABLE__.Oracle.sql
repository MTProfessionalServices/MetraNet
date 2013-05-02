
          SELECT id_request, status, id_account, id_ancestor_out,
                 id_corporation, hierarchy_path, acc_type, nm_space, ancestor_type
          FROM %%TMP_TABLE_NAME%% ORDER BY id_request ASC
      