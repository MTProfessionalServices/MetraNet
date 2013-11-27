
				CREATE OR REPLACE PROCEDURE CheckAccountStateDateRules (
				  p_id_acc integer,
					p_old_status in varchar2,
					p_new_status in varchar2,
					p_ref_date in date,
					status out integer)
				AS
					dt_crt DATE;
                    var_dummy number:=0;
				BEGIN
					 /* Rule 1: There should be no updates with dates earlier than inception
					  date*/
                      FOR i IN (SELECT dbo.mtstartofday(t_account.dt_crt) dt_crt
                                FROM t_account WHERE id_acc = p_id_acc) LOOP
                         dt_crt := i.dt_crt;
                      END LOOP;

					 IF (dbo.mtstartofday(p_ref_date) < dt_crt) THEN
					   /* MT_SETTING_START_DATE_BEFORE_ACCOUNT_INCEPTION_DATE_NOT_ALLOWED
						  (DWORD)0xE2FF002EL)*/
						 status := -486604754;
						 RETURN;
					 END IF;

					/* Rule 2: If updating from active to active state and there is usage
					 and there should be no updates with dates later than the existing date*/
					IF ((p_old_status = 'AC') AND 
							(p_new_status = 'AC') AND
							(dbo.mtstartofday(p_ref_date) > dt_crt)) 
                    THEN
                        select count(1) into var_dummy from dual
						where EXISTS (
						SELECT 
							id_acc
						FROM
							t_acc_usage
						WHERE
							id_acc = p_id_acc);
                        IF var_dummy <> 0 THEN
							/* ACCOUNT_CONTAINS_USAGE_ACTIVE_DATE_MOVE_IN_FUTURE_NOT_ALLOWED
							 (DWORD)0xE406000EL*/
							status := -469368818;
							return;
						END IF;
					END IF;

                    /* Rule 3: There should be no updates with dates later than 
                     inception date for the first interval, creating gaps in account state*/
                    IF (p_old_status = p_new_status) 
                    THEN
                        var_dummy := 0;
                        select count(1) into var_dummy from dual
                        where EXISTS( 
                        select 1
                        from t_account_state tas
                        where tas.status = p_new_status
                          and tas.id_acc = p_id_acc
                          and p_ref_date > vt_start
                          and p_ref_date <= vt_end
                          and vt_start = dt_crt);
                          
                        IF var_dummy <> 0
                        THEN
                            /* MT_START_DATE_AFTER_ACCOUNT_INCEPTION_DATE_NOT_ALLOWED
                             (DWORD)0xE2FF0059L*/
                            status := -486604711;
                            return;
                        END IF;
                    END IF;


					 status := 1;
				 END;
				