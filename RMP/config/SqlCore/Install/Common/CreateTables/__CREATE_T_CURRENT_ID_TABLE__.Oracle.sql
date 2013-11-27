/*
	<initialization table="t_current_id">
		<insert_only/>
	</initialization>
*/
		   CREATE TABLE t_current_id (id_current number(10) NOT NULL,
		   nm_current nvarchar2(20) NOT NULL, id_min_id number(10) NULL, CONSTRAINT PK_t_current_id
		   PRIMARY KEY (nm_current))
