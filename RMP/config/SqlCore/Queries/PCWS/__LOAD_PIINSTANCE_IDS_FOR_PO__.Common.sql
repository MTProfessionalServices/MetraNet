
                select 
                id_pi_instance
                from 
                t_pl_map %%UPDLOCK%%
                where 
                id_po = %%PO_ID%% 
                and 
                id_paramtable is null
                and 
                id_pi_instance_parent is null
                