CREATE OR REPLACE PROCEDURE GetCurrentAccountCycleRange(
   v_id_acc IN INT,
   v_curr_date IN DATE,
   v_StartCycle OUT DATE,
   v_EndCycle OUT DATE
)
AS
BEGIN
  SELECT dt_start,
         dt_end
  INTO   v_StartCycle,
         v_EndCycle
  FROM   t_usage_interval ui
         JOIN t_acc_usage_cycle acc
              ON  ui.id_usage_cycle = acc.id_usage_cycle
  WHERE  acc.id_acc = v_id_acc
         AND v_curr_date BETWEEN dt_start AND dt_end;
END;