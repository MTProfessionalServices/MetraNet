
    create or replace procedure InsertProductViewProperty
        (p_a_id_prod_view int,
        p_a_nm_name nvarchar2,
        p_a_nm_data_type nvarchar2,
        p_a_nm_column_name nvarchar2,
        p_a_b_required char,
        p_a_b_composite_idx char,
        p_a_b_single_idx char,
        p_a_b_part_of_key char,
        p_a_b_exportable char,
        p_a_b_filterable char,
        p_a_b_user_visible char,
        p_a_nm_default_value nvarchar2,
        p_a_n_prop_type int,
        p_a_nm_space nvarchar2,
        p_a_nm_enum nvarchar2,
        p_a_b_core char,
		a_description nvarchar2,
        p_a_id_prod_view_prop out int)
    as
    begin
        insert into t_prod_view_prop
        (
        id_prod_view_prop,
        id_prod_view,
        nm_name,
        nm_data_type,
        nm_column_name,
        b_required,
        b_composite_idx,
        b_single_idx,
        b_part_of_key,
        b_exportable,
        b_filterable,
        b_user_visible,
        nm_default_value,
        n_prop_type,
        nm_space,
        nm_enum,
        b_core,
		description
        )
        values
        (
        seq_t_prod_view_prop.nextval,
        p_a_id_prod_view,
        p_a_nm_name,
        p_a_nm_data_type,
        p_a_nm_column_name,
        p_a_b_required,
        p_a_b_composite_idx,
        p_a_b_single_idx,
        p_a_b_part_of_key,
        p_a_b_exportable,
        p_a_b_filterable,
        p_a_b_user_visible,
        p_a_nm_default_value,
        p_a_n_prop_type,
        p_a_nm_space,
        p_a_nm_enum,
        p_a_b_core,
		a_description
        );
        select seq_t_prod_view_prop.currval into p_a_id_prod_view_prop from dual;
    end;
  