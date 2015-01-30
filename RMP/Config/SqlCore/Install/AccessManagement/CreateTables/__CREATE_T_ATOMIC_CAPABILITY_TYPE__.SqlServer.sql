/*
	<initialization table="t_atomic_capability_type">
		<primary_key>
			<field name="tx_name"/>
		</primary_key>
	</initialization>
*/
				CREATE TABLE t_atomic_capability_type
				(id_cap_type int NOT NULL identity(1, 1),
				tx_guid varbinary(16) not null,
				tx_name nvarchar(255) NOT NULL,
				tx_desc nvarchar(255) NOT NULL,
				tx_progid nvarchar(255) NOT NULL,
				tx_editor nvarchar(255) NULL,
				CONSTRAINT pk_atomic_capability_type PRIMARY KEY (id_cap_type))

