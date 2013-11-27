/*
	<initialization table="t_dm_account_ancestor">
		<ignore_updates/>
		<join>
			<field name="id_dm_ancestor" remote_name="id_dm_acc" table="t_dm_account"/>
			<field name="id_dm_descendent" remote_name="id_dm_acc" table="t_dm_account"/>
		</join>
		<primary_key>
			<field name="id_dm_ancestor" remote_name="id_acc"/>
			<field name="id_dm_descendent" remote_name="id_acc"/>
		</primary_key>
	</initialization>
*/
					create table t_dm_account_ancestor
					(id_dm_ancestor number(10),
					id_dm_descendent number(10),
					num_generations number(10))

