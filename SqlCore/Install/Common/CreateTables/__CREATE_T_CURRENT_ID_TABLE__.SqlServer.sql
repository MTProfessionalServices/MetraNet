/*
	<initialization table="t_current_id">
		<insert_only/>
	</initialization>
*/
			     CREATE TABLE t_current_id (id_current int NOT NULL,
				 nm_current nvarchar(20) NOT NULL, id_min_id int NULL, CONSTRAINT PK_t_current_id
				 PRIMARY KEY CLUSTERED (nm_current))

