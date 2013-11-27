
        select 
          d.tx_desc as "View Name", 
          au.id_view as "View Id",  
          count(*) as "Count", 
          sum(au.amount) as "Amount"
        from t_acc_usage au 
        join t_description d 
          on au.id_view = d.id_desc 
          and d.id_lang_code =%%ID_LANG_CODE%%
	      where au.dt_crt between %%START_TIME%% and %%END_TIME%%
        group by au.id_view,d.tx_desc      
			 