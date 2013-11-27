
          select tx_path,
          acclist.id_acc
          from
          (select id_acc from t_account where id_acc in (%%DESC_LIST%%)) acclist
          LEFT OUTER JOIN t_account_ancestor on 
          (id_ancestor = 1 OR id_ancestor = -1) AND id_descendent = acclist.id_acc AND
          %%REFDATE%% between vt_start AND vt_end
				