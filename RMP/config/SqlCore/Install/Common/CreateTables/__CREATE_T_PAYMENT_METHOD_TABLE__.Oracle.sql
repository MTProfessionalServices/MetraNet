/*
	<initialization table="t_payment_method">
		<primary_key>
			<field name="nm_payment_method"/>
		</primary_key>
	</initialization>
*/
        CREATE TABLE t_payment_method (id_payment_method number(10) NOT NULL,
        nm_payment_method nvarchar2(40) NOT NULL, CONSTRAINT PK_t_payment_method
        PRIMARY KEY (id_payment_method))

