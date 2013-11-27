
      create procedure GetLocalizedSiteInfo (p_nm_space IN nvarchar2,
          p_tx_lang_code IN varchar2, p_id_site OUT int)
      as
      begin
        p_id_site := 0 ;
        select id_site into p_id_site from t_localized_site
        where nm_space = p_nm_space and tx_lang_code = p_tx_lang_code;
      exception
        when NO_DATA_FOUND
        then
          insert into t_localized_site(id_site, nm_space, tx_lang_code)
              values (seq_t_localized_site.NextVal, p_nm_space, p_tx_lang_code);
          if SQL%ROWCOUNT != 1 then
              p_id_site := -99;
          else
              select seq_t_localized_site.CurrVal into p_id_site from dual;
          end if;
        when others
        then
          p_id_site := -99;
      end;
       