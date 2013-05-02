
update t_site_user
set id_site = %%NEW_SITE_ID%%
where %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%LOGIN_ID%%')
   and id_site = %%SITE_ID%%
	      