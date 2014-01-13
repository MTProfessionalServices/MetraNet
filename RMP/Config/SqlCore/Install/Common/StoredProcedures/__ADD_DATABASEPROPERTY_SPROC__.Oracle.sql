
		CREATE OR REPLACE PROCEDURE adddatabaseproperty (
		property   NVARCHAR2,
		VALUE      NVARCHAR2
		)
		AS
		BEGIN
		DELETE FROM t_db_values
				WHERE parameter = property;

		INSERT INTO t_db_values
					(parameter, VALUE
					)
				VALUES (property, VALUE
					);
		END;
		