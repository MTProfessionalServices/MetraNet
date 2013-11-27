
		CREATE proc UpsertDescriptionV2             
		   @id_lang_code int,              
		   @a_nm_desc NVARCHAR(4000),              
		   @a_id_desc_in int,               
		   @a_id_desc int OUTPUT              
		  AS              
		  begin              
          
       
			  declare @var int              
		   IF (@a_id_desc_in IS NOT NULL and @a_id_desc_in <> 0)              
			BEGIN        
			  
			SELECT tx_desc FROM t_description WITH (UPDLOCK)   
			WHERE id_desc = @a_id_desc_in AND id_lang_code = @id_lang_code             
			IF @@ROWCOUNT > 0  
			BEGIN  
			   -- there was a previous entry              
			  UPDATE t_description        
			   SET              
				tx_desc = ltrim(rtrim(@a_nm_desc))              
			   WHERE              
				id_desc = @a_id_desc_in AND id_lang_code = @id_lang_code              
		  END  
		  ELSE              
			 BEGIN              
				 -- The entry didn't previously exist for this language code              
				SELECT id_desc FROM t_description with (UPDLOCK) WHERE id_desc = @a_id_desc_in
				 
				INSERT INTO t_description         
				 (id_desc, id_lang_code, tx_desc)              
				VALUES              
				 (@a_id_desc_in, @id_lang_code, ltrim(rtrim(@a_nm_desc)))              
				 END              
					  
			 -- continue to use old ID              
			 select @a_id_desc = @a_id_desc_in              
			END              
					  
		   ELSE              
			 begin              
			-- there was no previous entry              
			IF (@a_nm_desc IS NULL)              
			 begin              
			 -- no new entry              
			 select @a_id_desc = 0              
			 end              
			 ELSE              
			 BEGIN              
			  
			  -- generate a new ID to use              
			  INSERT INTO t_mt_id default values              
			  select @a_id_desc = @@identity              
			  
			  --SELECT id_mt from t_MT_ID with (updlock) where id_mt = @a_id_desc
			   
			  SELECT id_desc FROM t_description with (UPDLOCK) WHERE id_desc = @a_id_desc
					 
			  INSERT INTO t_description           
			   (id_desc, id_lang_code, tx_desc)              
			  VALUES              
			   (@a_id_desc, @id_lang_code, ltrim(rtrim(@a_nm_desc)))              
			  END              
		   END               
		   end
		