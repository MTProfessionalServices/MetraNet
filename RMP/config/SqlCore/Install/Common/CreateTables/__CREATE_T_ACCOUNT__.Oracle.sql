/*
	<initialization table="t_account">
		<ignore_updates/>
		<join>
			<field name="id_type" remote_name="id_type" table="t_account_type" insert_only="true"/>
		</join>
	</initialization>
*/
         CREATE TABLE t_account
         (id_acc number(10) NOT NULL,
					id_acc_ext raw(16) not null,
          ID_type number(10) not null,
					dt_crt date NOT NULL,
          CONSTRAINT PK_ACCOUNT PRIMARY KEY (id_acc)
          )
        
