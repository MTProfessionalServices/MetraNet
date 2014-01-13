
        UPDATE t_acc_template Set dt_crt=%%%SYSTEMDATE%%%,tx_name=N'%%NAME%%',
				tx_desc=N'%%DESC%%',b_applydefaultpolicy='%%APPLYPOLICY%%' 
				WHERE id_acc_template = %%TEMPLATEID%%
				