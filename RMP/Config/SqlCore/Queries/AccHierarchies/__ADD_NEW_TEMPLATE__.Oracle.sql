
				INSERT INTO t_acc_template 
				(id_acc_template,id_folder,dt_crt,tx_name,tx_desc,b_applydefaultpolicy, id_acc_type)
				select seq_t_acc_template.NextVal,
				%%ACCOUNTID%%,%%%SYSTEMDATE%%%,'%%NAME%%','%%DESC%%','%%APPLYPOLICY%%', '%%ACCOUNTIDTYPE%%'
				from dual
				