CREATE PROCEDURE GetCurrentAccountCycleRange
   @id_acc INT,
   @curr_date DATETIME,
   @StartCycle DATETIME OUTPUT,
   @EndCycle DATETIME OUTPUT
AS
  SELECT @StartCycle = dt_start,
         @EndCycle = dt_end
  FROM   t_usage_interval ui
         JOIN t_acc_usage_cycle acc
              ON  ui.id_usage_cycle = acc.id_usage_cycle
  WHERE  acc.id_acc = @id_acc
         AND @curr_date BETWEEN dt_start AND dt_end;