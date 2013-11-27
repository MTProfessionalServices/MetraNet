/*
	<initialization table="t_account">
		<ignore_updates/>
		<join>
			<field name="id_type" remote_name="id_type" table="t_account_type" insert_only="true"/>
		</join>
	</initialization>
*/
				CREATE TABLE t_account (id_acc int NOT NULL,
				id_acc_ext varbinary(16) not null,
				id_type int not null,
				dt_crt datetime NOT NULL,
				CONSTRAINT PK_ACCOUNT PRIMARY KEY CLUSTERED (id_acc))
			 
