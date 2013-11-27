/*
	<initialization table="t_usage_cycle_type">
		<primary_key>
			<field name="tx_desc"/>
		</primary_key>
	</initialization>
*/
           CREATE TABLE t_usage_cycle_type (
						id_cycle_type number(10) NOT NULL,
						tx_desc nvarchar2(255) NOT NULL,
						tx_cycle_type_method nvarchar2 (255) NOT NULL,
						n_proration_length number(10) NOT NULL,
						n_grace_period NUMBER(10) NULL, /* soft close grace period in days */
						CONSTRAINT PK_t_usage_cycle_type PRIMARY KEY
						(id_cycle_type))

