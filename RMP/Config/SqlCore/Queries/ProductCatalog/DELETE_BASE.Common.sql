
        /* delete display name in all locales first */
      begin
        delete from t_description where id_desc=(select n_display_name from t_base_props where id_prop = %%ID_PROP%%);
        delete from t_mt_id where id_mt=(select n_display_name from t_base_props where id_prop = %%ID_PROP%%);
        delete from t_base_props where id_prop = %%ID_PROP%%;
      end;
       