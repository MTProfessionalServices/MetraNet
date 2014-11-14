SELECT id_lang_code
      , tx_name
      , tx_desc
  FROM t_recevent_localize
  WHERE id_local = %%ID_EVENT%%

      