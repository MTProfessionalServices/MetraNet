
      CREATE or replace VIEW t_vw_GroupByLeaderName
      AS
      SELECT c_AccountingCode, c_LeaderName, IntervalID, AccountID, 
        SUM(amount) Amount, COUNT(*) NumConnections, 
        SUM(c_ConnectionMinutes) TotalConnectionMinutes
      FROM t_vw_ShowAllConnections
      GROUP BY AccountID, IntervalID, c_AccountingCode, c_LeaderName
			