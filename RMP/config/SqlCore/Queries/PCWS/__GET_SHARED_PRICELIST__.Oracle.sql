
              BEGIN
              open :1 for	select
                pl.id_pricelist                 ID,  
                pl.nm_currency_code  Currency,
                bp.nm_name                 Name,
                bp.nm_desc                   Description
              from t_pricelist pl
              inner join t_base_props bp on bp.id_prop = pl.id_pricelist
              where pl.n_type = 1 and pl.id_pricelist = %%PRICELIST_ID%% ;
              
              open :2 for select id_pt, nm_name from t_rsched rs inner join t_base_props bp on rs.id_pt = bp.id_prop where rs.id_pricelist = %%PRICELIST_ID%% ; 
              END;           
         