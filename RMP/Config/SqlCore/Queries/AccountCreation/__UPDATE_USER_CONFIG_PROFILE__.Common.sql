
					update t_profile set val_tag = N'%%TAG_VALUE%%', tx_desc = N'%%TEXT_DESCRIPTION%%' 
					where id_profile = %%PROFILE_ID%% 
					and id_typ_profile = %%PROFILE_TYPE_ID%% 
					and nm_tag = N'%%TAG_NAME%%'
			