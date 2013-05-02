

           select aui.dt_effective DateEffective from
           t_acc_usage_interval aui where aui.id_acc = %%ACCOUNT_ID%%
           and aui.id_usage_interval = %%INTERVAL_ID%%

        