
				INSERT INTO t_acc_template_props_pub 
				(id_prop,id_acc_template,nm_prop_class,nm_prop,nm_value)
				select  
				seq_t_acc_template_props_pub.NextVal,
				%%IDTEMPLATE%%,'%%CLASS%%','%%NAME%%','%%VALUE%%'
				from dual				