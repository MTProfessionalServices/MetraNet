
        select * 
				from t_sub s
				where s.id_acc = %%ID_ACC%% 
				and
				exists (
				  select * 
					from
					t_pl_map plm
					where
					plm.id_po=s.id_po
					and
					plm.id_paramtable is null
					and
					plm.id_pi_template= %%ID_PI%%
       )
			 order by s.vt_end desc
      