
          CREATE TRIGGER t_char_values_update_trigger
          ON t_char_values
          AFTER UPDATE
          AS
          insert into t_char_values_history(id_scv, id_entity, nm_value, c_start_date, c_end_date, c_spec_name, c_spec_type)
           select DISTINCT del.id_scv, del.id_entity, del.nm_value, del.c_start_date, CURRENT_TIMESTAMP, del.c_spec_name, del.c_spec_type
          from INSERTED ins, DELETED del WHERE ins.nm_value <> del.nm_value
        