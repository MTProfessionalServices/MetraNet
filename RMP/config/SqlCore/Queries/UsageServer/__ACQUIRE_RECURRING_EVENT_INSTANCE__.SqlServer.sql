
BEGIN TRAN

UPDATE t_recevent_inst SET 
  tx_status = '%%NEW_STATUS%%',
  b_ignore_deps = 'N',
  dt_effective = NULL
WHERE 
  id_instance = %%ID_INSTANCE%% AND
  tx_status = '%%CURRENT_STATUS%%'

-- the instance may not have been acquired if 
-- another billing server picked it up first
IF @@ROWCOUNT > 0 
  INSERT INTO t_recevent_run
  (
    id_run,
    id_instance,
    tx_type,
    id_reversed_run,
    tx_machine,
    dt_start,
    dt_end,
    tx_status,
    tx_detail
  )
  VALUES 
  (
    %%ID_RUN%%,
    %%ID_INSTANCE%%,
    '%%TX_TYPE%%',
    %%ID_REVERSED_RUN%%,
    '%%TX_MACHINE%%',
    %%%SYSTEMDATE%%%,
    NULL,
    'InProgress',
    NULL
  )

COMMIT
