/*
	<initialization table="t_stored_procedure_table_lock">
		<primary_key>
			<field name="c_stored_procedure_name"/>
		</primary_key>
		<insert_only/>
	</initialization>
*/
			CREATE TABLE t_stored_procedure_table_lock
			(
				c_row_id INT IDENTITY,
				c_stored_procedure_name SYSNAME UNIQUE,
				CONSTRAINT [t_stored_procedure_table_lock_PK] PRIMARY KEY CLUSTERED 
				(
					[c_row_id] ASC
				) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = OFF) ON [PRIMARY]
			) ON [PRIMARY]

			INSERT t_stored_procedure_table_lock ( c_stored_procedure_name ) VALUES( 'AcquireRecurringEventInstance' );
