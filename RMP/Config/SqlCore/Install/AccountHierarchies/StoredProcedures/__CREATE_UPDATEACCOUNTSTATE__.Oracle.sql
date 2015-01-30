
				CREATE OR REPLACE PROCEDURE updateaccountstate (
					p_id_acc IN integer,
					p_new_status IN varchar2,
					p_start_date IN DATE,
					p_system_date IN DATE,
					status OUT INTEGER
					/*,v_sqlcode OUT number
					,v_sqlerrm OUT varchar2*/
					)
				AS
					varMaxDateTime DATE;
					realstartdate DATE;
					realenddate DATE;
				BEGIN
					status := 0;
					/* Set the maxdatetime into a variable*/
					varMaxDateTime := dbo.MTMaxDate; 
					realstartdate := dbo.mtstartofday(p_start_date);
				    realenddate   := dbo.mtstartofday(varMaxDateTime) ;
					CreateAccountStateRecord (
					  p_id_acc, 
						p_new_status, 
						realstartdate,
						realenddate,
						p_system_date,
						status);
/*
				EXCEPTION WHEN OTHERS THEN 
					--v_sqlcode := SQLCODE;
					--v_sqlerrm := SQLERRM;
					status := -1;
					ROLLBACK;
					RETURN;
*/
				END;
			