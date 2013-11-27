
				CREATE STATISTICS Statistic_id_sub ON dbo.t_vw_allrateschedules_po (id_sub) 
				CREATE STATISTICS Statistic_id_pricelist ON dbo.t_vw_allrateschedules_pl (id_pricelist) 
				CREATE STATISTICS Statistic_id_po ON dbo.t_vw_allrateschedules_po (id_po) 
        CREATE STATISTICS Statistic_id_sub ON dbo.t_vw_allrateschedules_po_icb (id_sub)  
        CREATE STATISTICS Statistic_id_po ON dbo.t_vw_allrateschedules_po_icb (id_po)  
        CREATE STATISTICS Statistic_id_sub ON dbo.t_vw_allrateschedules_po_noicb (id_sub)  
        CREATE STATISTICS Statistic_id_po ON dbo.t_vw_allrateschedules_po_noicb (id_po) 
 		