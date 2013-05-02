/*
	<initialization table="t_calc_engine">
		<primary_key>
			<field name="nm_name"/>
		</primary_key>
	</initialization>
*/
		create table t_calc_engine (
		id_engine int identity(1, 1) not null,
		nm_name nvarchar(255),
		constraint pk_t_calc_engine primary key(id_engine)
		)

