update t_be_cor_ui_Site
set c_AuthenticationNamespace = 'mt'
where c_AuthenticationNamespace IS NULL or c_AuthenticationNamespace = ''