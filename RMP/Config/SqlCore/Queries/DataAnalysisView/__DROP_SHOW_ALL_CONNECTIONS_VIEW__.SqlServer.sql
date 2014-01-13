
      if exists (select * from sysobjects where name = 't_vw_ShowAllConnections')
	      drop view t_vw_ShowAllConnections
			