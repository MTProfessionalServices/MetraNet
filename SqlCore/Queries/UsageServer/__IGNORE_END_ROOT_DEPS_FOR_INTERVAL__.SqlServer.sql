
/* ===========================================================
   Set the ignoredeps status of the EndRoot event (in t_recevent_inst) for the given billingGroupId to 'Y'.
   =========================================================== */
UPDATE ri
SET ri.b_ignore_deps = 'Y'
FROM t_recevent_inst ri 
INNER JOIN t_recevent re 
  ON re.id_event = ri.id_event
WHERE id_arg_interval = %%ID_INTERVAL%% AND
      re.tx_type = 'Root'
   