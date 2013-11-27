
          CREATE PROC GetLocalizedSiteInfo @nm_space nvarchar(40),
            @tx_lang_code varchar(10), @id_site int OUTPUT
          as
          if not exists (select * from t_localized_site where
            nm_space = @nm_space and tx_lang_code = @tx_lang_code)
          begin
            insert into t_localized_site (nm_space, tx_lang_code)
              values (@nm_space, @tx_lang_code)
            if ((@@error != 0) OR (@@rowcount != 1))
            begin
              select @id_site = -99
            end
            else
            begin
              select @id_site = @@identity
            end
          end
          else
          begin
            select @id_site = id_site from t_localized_site
              where nm_space = @nm_space and tx_lang_code = @tx_lang_code
          end
			 