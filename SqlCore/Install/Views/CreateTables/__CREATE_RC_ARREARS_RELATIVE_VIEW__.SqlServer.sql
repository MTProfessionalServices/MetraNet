
CREATE VIEW t_vw_rc_arrears_relative
AS
-- Obtain the associated subscription period, recurring cycle
-- and account usage cycle for each of the subscription recurring items
SELECT 
	t_sub.id_po,
	t_pl_map.id_pi_instance,
	t_pl_map.id_pi_template,
	t_pl_map.id_paramtable,
	t_pl_map.id_pi_type,
	t_sub.id_acc,
	t_sub.vt_start sub_dt_start,
	t_sub.vt_end sub_dt_end,
	t_recur.id_usage_cycle recur_usage_cycle_id,
	t_recur.b_advance,
	t_recur.b_prorate_on_activate,
  t_recur.b_prorate_instantly,
	t_recur.b_prorate_on_deactivate,
	t_recur.b_fixed_proration_length,
	t_acc_usage_cycle.id_usage_cycle acc_usage_cycle_id
FROM 
	t_pl_map,
	t_recur,
	t_sub, 
	t_acc_usage_cycle
WHERE 
	t_pl_map.id_pi_instance = t_recur.id_prop AND
	t_pl_map.id_po = t_sub.id_po AND
	t_acc_usage_cycle.id_acc = t_sub.id_acc
