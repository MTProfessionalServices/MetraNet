/*
	<initialization table="t_account_ancestor">
		<ignore_updates/>
		<primary_key>
			<field name="id_ancestor"/>
			<field name="id_descendent"/>
		</primary_key>
	</initialization>
*/
				create table t_account_ancestor(id_ancestor int not null,
				id_descendent int not null,
				num_generations int not null,
				b_children char(1) default 'N',
				vt_start datetime,
				vt_end datetime,
				tx_path varchar(4000) not null,
				CONSTRAINT b_children_check1 CHECK (b_children = 'Y' OR b_children = 'N'),
				CONSTRAINT num_generations_check1 CHECK (num_generations >= 0),
				CONSTRAINT date_ancestor_check1 check ( vt_start <= vt_end)
				)

