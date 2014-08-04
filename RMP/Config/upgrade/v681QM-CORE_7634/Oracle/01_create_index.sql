-- Create a function-based index for ONLY the Failed status.
-- This is highly selective, and will be small and cheap to maintain.

CREATE INDEX idx_s_billgroup_member_history
   ON t_billgroup_member_history (DECODE (tx_status, 'Failed', 1, NULL));