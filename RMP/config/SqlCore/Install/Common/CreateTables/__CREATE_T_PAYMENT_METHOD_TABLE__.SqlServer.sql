/*
	<initialization table="t_payment_method">
		<primary_key>
			<field name="nm_payment_method"/>
		</primary_key>
	</initialization>
*/
          	    CREATE TABLE t_payment_method (
          	    id_payment_method int NOT NULL,
				nm_payment_method nvarchar(40) NOT NULL,
				CONSTRAINT PK_t_payment_method PRIMARY KEY CLUSTERED(id_payment_method))

