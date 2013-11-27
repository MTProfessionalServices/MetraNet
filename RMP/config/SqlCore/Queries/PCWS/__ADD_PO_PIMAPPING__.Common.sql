
                insert into t_pl_map 
                (id_paramtable,id_pi_type,id_pi_template,id_pi_instance,
                id_pi_instance_parent,id_po,id_pricelist,b_canICB, dt_modified)
                values (%%ID_PT%%,%%ID_PI_TYPE%%,%%ID_PI_TEMPLATE%%,%%ID_PI_INSTANCE%%,
                %%ID_PI_INSTANCE_PARENT%%,%%ID_PO%%,%%ID_PL%%,'%%CANICB%%', %%%SYSTEMDATE%%%)
            