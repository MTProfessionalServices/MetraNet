/*
	<initialization table="t_account_ancestor">
		<ignore_updates/>
		<primary_key>
			<field name="id_ancestor"/>
			<field name="id_descendent"/>
		</primary_key>
	</initialization>
*/
				create table t_account_ancestor(id_ancestor number(10) not null,
				id_descendent number(10) not null,
				num_generations NUMBER(10) not null,
				b_children char(1) default 'N',
				vt_start date,
				vt_end date,
				tx_path varchar2(4000) not null,
				CONSTRAINT b_children_check1 CHECK (b_children = 'Y' OR b_children = 'N'),
				CONSTRAINT num_generations_check1 CHECK (num_generations >= 0),
				CONSTRAINT date_ancestor_check1 check ( vt_start <= vt_end)
				)			 

