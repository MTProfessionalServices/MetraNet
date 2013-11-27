/*
	<initialization table="t_usage_cycle_type">
		<primary_key>
			<field name="tx_desc"/>
		</primary_key>
	</initialization>
*/
CREATE TABLE t_usage_cycle_type
(
  id_cycle_type INT NOT NULL,
  tx_desc nvarchar(255) NOT NULL,
  tx_cycle_type_method nvarchar(255) NOT NULL, -- TODO: remove this column
  n_proration_length INT NOT NULL,
  n_grace_period INT NULL, -- soft close grace period in days
  CONSTRAINT PK_t_usage_cycle_type PRIMARY KEY CLUSTERED (id_cycle_type)
)

