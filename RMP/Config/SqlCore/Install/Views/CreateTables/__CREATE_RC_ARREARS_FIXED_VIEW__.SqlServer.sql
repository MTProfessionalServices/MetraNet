
CREATE VIEW t_vw_rc_arrears_fixed
AS
-- Obtain the associated subscription period and recurring cycle
-- for each of the subscription recurring items 
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
	t_recur.b_fixed_proration_length
FROM 
	t_pl_map,
	t_recur,
	t_sub
WHERE 
	t_pl_map.id_pi_instance = t_recur.id_prop and
	t_pl_map.id_po = t_sub.id_po
