     
				select tx_desc TimeZoneIDFQN from t_av_internal,t_description,t_language 
				where  t_av_internal.id_acc = %%ACCOUNT_ID%% and 
				t_av_internal.c_TimeZoneID=t_description.id_desc and 
				lower(t_language.tx_lang_code)='%%LANGUAGE%%' and t_language.id_lang_code=t_description.id_lang_code
 			