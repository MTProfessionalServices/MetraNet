
		create or replace procedure InsertIntoCatalogTable
			(p_name nvarchar2, p_table_name nvarchar2, p_description nvarchar2,
			p_UpdateMode varchar2, p_QueryPath nvarchar2,
			p_CreateQueryTag nvarchar2, p_DropQueryTag nvarchar2,p_InitQueryTag nvarchar2,
			p_FullQueryTag nvarchar2, p_ProgId nvarchar2,
			p_IdRevision number, p_Checksum varchar2,
			p_id_mv out number)
		as
		begin
			insert into t_mview_catalog(id_mv, name, table_name, description, update_mode, query_path, create_query_tag, drop_query_tag, init_query_tag, full_query_tag, progid, id_revision, tx_checksum)
			values(seq_tmp_t_mview_catalog.nextval, p_name, p_table_name, p_description, p_UpdateMode,
			       p_QueryPath, p_CreateQueryTag, p_DropQueryTag, p_InitQueryTag, p_FullQueryTag, p_ProgId, p_IdRevision, p_Checksum);
			select seq_tmp_t_mview_catalog.currval into p_id_mv from dual;
		end;
		