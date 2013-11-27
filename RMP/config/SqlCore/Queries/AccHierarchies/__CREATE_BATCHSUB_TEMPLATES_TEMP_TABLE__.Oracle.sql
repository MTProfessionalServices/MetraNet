
				BEGIN 
					IF table_exists('%%TMP_TABLE_NAME%%') THEN
						EXECUTE IMMEDIATE 'DROP TABLE %%TMP_TABLE_NAME%%';
					END IF;
					EXECUTE IMMEDIATE 'CREATE TABLE %%TMP_TABLE_NAME%% ' ||
											/* Input Values - Required values are specified as NOT NULL. */
					            /* Account Related */
                      '(id_acc number(10) NOT NULL, ' ||
                      'id_ancestor number(10) NOT NULL, ' ||
                      'id_corporate number(10) NOT NULL, ' ||
                      'dt_acc_start date NOT NULL, ' ||
                      'dt_acc_end date NOT NULL, ' ||
											/* Ouput or Return Values */
					            /* Template Related */
                      'id_acc_type number(10) NOT NULL, ' ||
                      'id_template number(10) NULL)';
				END;
        