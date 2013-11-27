CREATE OR REPLACE procedure UpsertDescriptionV2(
				temp_id_lang_code t_description.ID_LANG_CODE%type,
				a_nm_desc t_description.TX_DESC%type,
				a_id_desc_in t_description.ID_DESC%type,
				a_id_desc out int)
				AS
				BEGIN
          /* CORE-921 add trim around a_nm_desc */ 
					IF a_id_desc_in IS NOT NULL and a_id_desc_in <> 0
					THEN
						BEGIN
						/* there was a previous entry */
						UPDATE t_description
						SET
							tx_desc = trim(a_nm_desc)
						WHERE
						(id_desc = a_id_desc_in) AND (id_lang_code = temp_id_lang_code);
						/* continue to use old ID */
						a_id_desc := a_id_desc_in;
						
						IF SQL%ROWCOUNT = 0 THEN
						   	INSERT INTO t_description
							(id_desc, id_lang_code, tx_desc)
						VALUES
							(a_id_desc_in, temp_id_lang_code, trim(a_nm_desc));
						END IF;
						
						/* continue to use old ID  */
						a_id_desc := a_id_desc_in;
						END;
					ELSE
						/* there was no previous entry */
						IF a_nm_desc IS NULL
						THEN
							/* no new entry */
						a_id_desc := 0;
						ELSE
							BEGIN
							/* generate a new ID to use */
							INSERT INTO t_mt_id VALUES(seq_t_mt_id.NEXTVAL);
							select seq_t_mt_id.currval into a_id_desc from dual;
							INSERT INTO t_description
							(id_desc, id_lang_code, tx_desc)
							VALUES
							(a_id_desc, temp_id_lang_code, trim(a_nm_desc));
							END;
						END IF;
					END IF;
				END;
		