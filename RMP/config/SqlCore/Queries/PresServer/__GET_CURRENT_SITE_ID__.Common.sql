
select ls.id_site 
from t_localized_site ls, t_site_user su 
where su.id_site = ls.id_site 
  and %%%UPPER%%%(su.nm_login) = %%%UPPER%%%(N'%%LOGIN_ID%%') 
  and %%%UPPER%%%(ls.nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
			