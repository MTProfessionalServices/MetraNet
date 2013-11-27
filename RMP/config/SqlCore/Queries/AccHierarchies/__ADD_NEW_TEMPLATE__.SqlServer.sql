
				INSERT INTO t_acc_template 
				(id_folder,dt_crt,tx_name,tx_desc,b_applydefaultpolicy, id_acc_type)
				select 	%%ACCOUNTID%%,%%%SYSTEMDATE%%%,N'%%NAME%%',N'%%DESC%%','%%APPLYPOLICY%%', '%%ACCOUNTIDTYPE%%'
				