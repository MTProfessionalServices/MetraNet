
				select count(id_acc) numfolders from t_av_internal where 
				id_acc in (%%ACCLIST%%) and c_folder = '1'
			