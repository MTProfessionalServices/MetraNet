
                select 
                bp.id_prop ID, 
                bp.nm_name Name,  
                bp.nm_desc Description, 
                t_pi.nm_servicedef ServiceDefName, 
                t_pi.nm_productview ProductViewName, 
                t_pi.id_parent ParentPriceableItem, 
                bp.n_kind Kind  
                from  
                t_base_props bp 
                join  
                t_pi on bp.id_prop = t_pi.id_pi
            