/*
	<initialization table="t_dm_account">
		<ignore_updates/>
		<identity sequence="seq_t_dm_account" field="id_dm_acc"/>
		<primary_key>
			<field name="id_acc"/>
		</primary_key>
	</initialization>
*/
                    create table t_dm_account
                    (id_dm_acc number(10) not null,
                    id_acc number(10),
                    vt_start date,
                    vt_end date)

