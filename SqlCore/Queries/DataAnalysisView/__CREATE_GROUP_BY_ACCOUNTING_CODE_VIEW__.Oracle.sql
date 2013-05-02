
      CREATE or replace VIEW t_vw_GroupByAccountingCode
      AS
     SELECT AccountID, c_AccountingCode, SUM(amount) Amount,
	    SUM(c_ConnectionMinutes) TotalConnectionMinutes,
        AVG(c_ConnectionMinutes) AverageConnectionMinutes, 
        MAX(c_ConnectionMinutes) MaxConnectionMinutes, 
        MIN(c_ConnectionMinutes) MinConnectionMinutes, 
        MAX(amount) MaxConnectionCharge, MIN(amount) 
        MinConnectionCharge, AVG(amount) AverageConnectionCharge, 
        IntervalID, COUNT(*) NumConnections
        FROM t_vw_ShowAllConnections
        GROUP BY AccountID, IntervalID, c_AccountingCode	
			