/*
	<initialization table="t_atomic_capability_type">
		<primary_key>
			<field name="tx_name"/>
		</primary_key>
	</initialization>
*/
				CREATE TABLE t_atomic_capability_type (id_cap_type number(10) NOT NULL,
				tx_guid RAW(16) NOT NULL, 
				tx_name NVARCHAR2(255) NOT NULL,
				tx_desc NVARCHAR2(255) NOT NULL,
				tx_progid NVARCHAR2(255) NOT NULL,
				tx_editor NVARCHAR2(255) NULL,
				CONSTRAINT pk_atomic_capability_type PRIMARY KEY (id_cap_type))

