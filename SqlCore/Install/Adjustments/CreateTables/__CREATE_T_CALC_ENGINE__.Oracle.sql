/*
	<initialization table="t_calc_engine">
		<primary_key>
			<field name="nm_name"/>
		</primary_key>
	</initialization>
*/
        create table t_calc_engine (
        id_engine number(10)  not null primary key,
        nm_name nvarchar2(255)
        )

