
                select
                id_prop ID,
                id_lang_code LanguageCode,
                nm_display_name DisplayName,
                nm_desc Description
                from t_vw_base_props
                where id_prop in (%%PITYPE_IDS%%)
                order by ID, LanguageCode
            