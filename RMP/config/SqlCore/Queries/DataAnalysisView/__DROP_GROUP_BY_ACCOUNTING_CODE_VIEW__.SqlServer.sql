
      if exists (select * from sysobjects where name = 't_vw_GroupByAccountingCode')
	      drop view t_vw_GroupByAccountingCode
			