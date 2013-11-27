/*
	<initialization table="t_mt_id">
		<identity_insert/>
	</initialization>
*/
      	insert into t_MT_ID (id_mt) values (decode(seq_t_mt_id.nextval,0,0,0))
