
			select t_description.tx_desc from t_base_props,t_description where t_base_props.id_prop = %%INSTANCE_ID%% AND
			t_description.id_desc = t_base_props.n_display_name AND t_description.id_lang_code = %%LANGUAGE_CODE%%
      