	 DoItAgain:
         delete top (5000)
          from t_tax_details
          where id_tax_run=%%RUN_ID%%
	IF @@ROWCOUNT>0
        GOTO DoItAgain
        /* if object_id('t_tax_details') is not null
          while exists(select 1 from t_tax_details where id_tax_run=%%RUN_ID%%) 
          begin
            delete top (5000)
            from t_tax_details
            where id_tax_run=%%RUN_ID%%
	  end*/
       