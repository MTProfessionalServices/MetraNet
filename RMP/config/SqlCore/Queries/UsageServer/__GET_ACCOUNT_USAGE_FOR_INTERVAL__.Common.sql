

          select aui.id_acc AccountID, ui.id_interval IntervalID from
          t_acc_usage_interval aui, t_usage_interval ui where
          ui.id_interval = %%INTERVAL_ID%% and aui.id_usage_interval =
          ui.id_interval

        