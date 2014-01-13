
            select count(*) SchedExist from t_pl_map map
            inner join t_pricelist pl on map.id_pricelist = pl.id_pricelist
            inner join t_rsched sched on pl.id_pricelist = sched.id_pricelist and map.id_paramtable = sched.id_pt
            where id_po = %%ID_PO%% and sched.id_sched = %%RSCHED_ID%%
          