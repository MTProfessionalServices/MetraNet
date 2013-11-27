/*
	<initialization table="t_dm_account">
		<ignore_updates/>
		<primary_key>
			<field name="id_acc"/>
		</primary_key>
	</initialization>
*/
					create table t_dm_account
					(id_dm_acc integer identity(1000,1),
					id_acc int,
					vt_start datetime,
					vt_end datetime)

