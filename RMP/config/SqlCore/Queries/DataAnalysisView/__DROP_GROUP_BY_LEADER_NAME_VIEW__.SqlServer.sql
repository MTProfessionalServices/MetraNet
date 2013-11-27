
      if exists (select * from sysobjects where name = 't_vw_GroupByLeaderName')
	      drop view t_vw_GroupByLeaderName
			