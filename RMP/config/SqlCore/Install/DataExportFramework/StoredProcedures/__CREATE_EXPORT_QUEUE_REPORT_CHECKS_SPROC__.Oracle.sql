                                      
              CREATE OR REPLACE FUNCTION Export_QueueReportChecks
              (
                v_source IN VARCHAR2 DEFAULT NULL ,
                v_id_rep_IN IN NUMBER DEFAULT NULL ,
                v_id_rep_instance_id_IN IN NUMBER DEFAULT NULL,
                v_system_datetime DATE DEFAULT NULL
              )
              RETURN NUMBER
              AS
                 /*
                     NOTES
                     This proc enforces any extra conditions that must be met prior to a report being put on the queue by using configurable dynamic queries
                     that are stored in a table and associated with specific reports. 
                     There are a few rules that must be followed for this framework though.
                     1.    The query must only return a single value: 
                             1 Means that there are warnings and the report cannot be run.
                             0 Means that no warnings were found and the report may be placed on the queue.
                             The value must be placed into a variable called @warningOUT. (See the example query below in #7)
                     2.    The query must filter on id_rep or id_rep_instance_id.  (See the example below in #7)
                     3.    The query must be a test string - so you will need to put the appropriate number of ticks in around text strings.
                     4.    The query must run very fast.  Do not put any queries in here that run for more than a few seconds.
                     5.    The t_rp_queue_report_queries table holds the queries that need to be run.
                     6.    The t_rp_queue_report_checks table contains information such as report to check, the query to run, and some status information.
                     
                     How to set up a new check:
                             1.    Write your query in SQL Analyzer.  
                                     - It should only return a 0 or 1 into @warningOUT.
                                     - It should filter on id_rep or id_rep_instance_id.
                                     - It should run in < 3 seconds if possible.
                                     - The id_query field must be unique.
                                     - It should then be turned into a string so it can be run using dynamic SQL.
                                     Example of creating a new query check:
                                     insert into t_rp_queue_report_queries values ('__CHECK_ID_SESS_BOOKENDS__', 'Check to make sure the current days data has been built in                     t_dtcc_id_sess_bookends',  
                                     'select @warningOUT = CASE count(*) when 0 then 1 else 0 end
                                     from 
                                     (select convert(varchar, usage_date, 101) as usage_date 
                                     from t_dtcc_id_sess_bookends A with (nolock)
                                     inner join t_rp_report_instance B with (nolock) on A.usage_date = convert(varchar, dt_next_run, 101) 
                                     where id_rep = @id_rep OR id_rep_instance_id = @id_rep_instance_id) A')
                 
                             2.    Associate your new query with the reports it should check.
                                     - The source column needs to be "Scheduled", "EOP", or "Ad-Hoc", depending on when/where the check will be done. (Scheduled is the only supported type at ths                     time).
                                     - The id_rep field should be specified only when you want all instances of the id_rep to be checked.  If not, leave this field as NULL.
                                     - The id_rep_instance_id should only be specified if you want to limit this check to a given instance of an id_rep.
                                     - The id_query should be set to the id_query you created in t_rp_queue_report_queries.
                                     - The log_error_delay field should be set to the number of minutes that you want to wait to send a message to the t_xrep_message_log table.
                                             - Lets say that it is common for usage to come in late for NSCC. We know that we want the daily transaction reports to run at 10:00
                                                 each morning, but we are willing to wait for 1 additional hour before panicking.  
                                                 In this case, set the log_error_delay to 60, meaning that while the report is still not able
                                                 to run due to a check we installed, no warning messages will be sent until 1 hour has passed.  From this point on, a reminder
                                                 message will be sent every 1 hours as well.
                                             - Set this value to 0 of you want to immediately send a warning.
                                     - The last_status and last_message_log_date field should be set to NULL. 
                                     Example of associating a new report with a query check:
                                     insert into t_rp_queue_report_checks values ('Scheduled', NULL, 5, '__CHECK_ID_SESS_BOOKENDS__', 0, NULL, NULL, 0, NULL, NULL)
                 
                 
                     OPEN
                     1.     
                         
                     CLOSED
                     1.
                     */
                 v_sql VARCHAR2(4000);
                 v_id_Query VARCHAR2(100);
                 v_last_message_log_date DATE;
                 v_log_error_delay NUMBER(10,0);
                 v_email_a_warning NUMBER(10,0);
                 v_email_subject NVARCHAR2(200);
                 v_email_address VARCHAR2(200);
                 v_report_date DATE;
                 v_parms VARCHAR2(1000);
                 v_today VARCHAR2(20);
                 v_rollout VARCHAR2(20);
                 v_report_desc VARCHAR2(200);
                 v_ParmDefinition NVARCHAR2(500);
                 v_Warning NUMBER(10,0);
                 /* Look for any checks that apply to the current report (NOTE that the checks can come from Scheduled, EOP, or Ad-Hoc - so filter on this too.) */
                 CURSOR check_csr
                   IS SELECT B.id_query ,
                 B.query_string ,
                 last_message_log_date ,
                 log_error_delay ,
                 NVL(email_a_warning, 0) ,
                 email_subject ,
                 email_address 
                   FROM t_export_queue_report_checks A
                   JOIN t_export_queue_report_queries B
                    ON A.id_query = B.id_query
                  WHERE source = v_source
                   AND ( id_rep = v_id_rep_IN
                   OR id_rep_instance_id = v_id_rep_instance_id_IN );
              
              BEGIN
                 SELECT dt_next_run ,
                        c_rep_instance_desc 
              
                   INTO v_report_date,
                        v_report_desc
                   FROM t_export_report_instance 
                  WHERE id_rep_instance_id = v_id_rep_instance_id_IN;
                 OPEN check_csr;
                 FETCH check_csr INTO v_id_query,v_sql,v_last_message_log_date,v_log_error_delay,v_email_a_warning,v_email_subject,v_email_address;
                 v_Warning := 0 ;
                 WHILE check_csr%FOUND
                 LOOP 
                    
                    BEGIN
                       EXECUTE IMMEDIATE v_SQL USING v_id_rep_IN, v_id_rep_instance_id_IN, OUT v_Warning;
                       IF v_Warning > 0 THEN
                       
                       BEGIN
                          /* If the last_message_log_date is null, we need to set it as the starting point for knowing when to send a message to the t_xrep_message_log table.
                                      We don't want to send this message each time because it will fill up the log with trash. */
                          IF v_last_message_log_date IS NULL THEN
                             UPDATE t_export_queue_report_checks
                                SET last_message_log_date = v_system_datetime
                                WHERE id_query = v_id_query
                               AND ( id_rep = v_id_rep_IN
                               OR id_rep_instance_id = v_id_rep_instance_id_IN );
                          ELSE
                             /* Insert a row into the message log if the delay has been satisfied. */
                             IF ROUND((v_system_datetime - v_last_message_log_date)*24*60) >= v_log_error_delay THEN
                             
                             BEGIN
                                UPDATE t_export_queue_report_checks
                                   SET last_message_log_date = v_system_datetime
                                   WHERE id_query = v_id_query
                                  AND ( id_rep = v_id_rep_IN
                                  OR id_rep_instance_id = v_id_rep_instance_id_IN );
                                INSERT INTO t_export_log
                                  VALUES ( v_id_rep_IN, v_id_rep_instance_id_IN, v_system_datetime, 'CHECK', 'Report could not be placed on the workqueue due to     configured warning: ' || v_id_query );
                                /* Do we want to send an e-mail warning too? */
                                IF v_email_a_warning = 1 THEN
                                
                                BEGIN
                                   DBMS_OUTPUT.PUT_LINE('EMAIL OPTION IS NOT FUNCTIONAL YET');
                                END;
                                END IF;
                             END;
                             END IF;
                          END IF;
                          UPDATE t_export_queue_report_checks
                             SET last_status = v_source || ' Report Instance ' || CAST(v_id_rep_instance_id_IN AS VARCHAR2(4000)) || ' (' || v_report_desc || ') ' || 'Was Not Run for Report Date ' || to_char(v_report_date, 'MM/DD/YYYY') || ' Due to This Rule.'
                             WHERE id_query = v_id_query
                            AND ( id_rep = v_id_rep_IN
                            OR id_rep_instance_id = v_id_rep_instance_id_IN );
                          CLOSE check_csr;
                          /* We only care about the 1st warning - so kill the loop and return to calling process if there is a warning. */
                          RETURN v_Warning;
                       END;
                       ELSE
                       
                       BEGIN
                          UPDATE t_export_queue_report_checks
                             SET last_status = 'No Warnings Found',
                                 last_message_log_date = NULL
                             WHERE id_query = v_id_query
                            AND ( id_rep = v_id_rep_IN
                            OR id_rep_instance_id = v_id_rep_instance_id_IN );
                       END;
                       END IF;
                       FETCH check_csr INTO v_id_query,v_sql,v_last_message_log_date,v_log_error_delay,v_email_a_warning,v_email_subject,v_email_address;
                    END;
                 END LOOP;
                 CLOSE check_csr;
                 RETURN v_Warning;
              END;
	 