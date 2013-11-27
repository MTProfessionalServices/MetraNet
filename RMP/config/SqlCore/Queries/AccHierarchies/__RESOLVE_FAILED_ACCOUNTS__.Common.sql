
				select id_acc,displayname
				from VW_MPS_ACC_MAPPER
				where id_acc in (%%RESOLVEIDS%%)
        order by id_acc asc
			