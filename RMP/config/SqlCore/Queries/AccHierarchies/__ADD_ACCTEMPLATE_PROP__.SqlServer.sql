
				INSERT INTO t_acc_template_props_pub 
				(id_acc_template,nm_prop_class,nm_prop,nm_value)
				select  
				%%IDTEMPLATE%%,'%%CLASS%%',N'%%NAME%%',N'%%VALUE%%'				
				