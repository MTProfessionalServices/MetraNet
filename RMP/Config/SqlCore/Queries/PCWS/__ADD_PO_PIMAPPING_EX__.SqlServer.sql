
				 declare @id_pi_type int
                 declare @id_pi_template int
                 declare @id_pi_instance_parent int
                 
                 select 
                 @id_pi_type = id_pi_type,
                 @id_pi_template = id_pi_template,
                 @id_pi_instance_parent = id_pi_instance_parent               
                 from t_pl_map with (updlock)
                    where id_pi_instance = %%ID_PI%% and id_po = %%ID_PO%% and id_paramtable is NULL

                insert into t_pl_map 
                (id_paramtable,id_pi_type,id_pi_template,id_pi_instance,
                id_pi_instance_parent,id_po,id_pricelist,b_canICB, dt_modified)
                values (%%ID_PTD%%,@id_pi_type,@id_pi_template,%%ID_PI%%,
                              @id_pi_instance_parent,%%ID_PO%%,%%ID_PL%%,'%%CAN_ICB%%', %%%SYSTEMDATE%%%)
            