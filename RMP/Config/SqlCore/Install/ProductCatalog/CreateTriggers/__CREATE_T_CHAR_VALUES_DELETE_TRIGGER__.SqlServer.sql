
        CREATE TRIGGER t_char_values_delete_trigger
        ON t_char_values
        AFTER DELETE
        AS
        insert into t_char_values_history(id_scv, id_entity, nm_value, c_start_date,
        c_end_date, c_spec_name, c_spec_type)
        select id_scv, id_entity, nm_value, c_start_date,
        CURRENT_TIMESTAMP, c_spec_name, c_spec_type
        from deleted
      