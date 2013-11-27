
/*
    Proc: PausePipelineProcessing

    Pauses pipeline processing. Waits up to 2 minutes for the pipeline to pause.
*/
CREATE OR REPLACE
PROCEDURE PausePipelineProcessing(
    p_state INT
) 
authid current_user
AS
    v_status INT := CASE p_state WHEN 0 THEN 0 ELSE 1 END; /* ensure only 0 or 1 is a valid status */
    v_timeout INT := 0;
    v_pipline_processing int := 1;
BEGIN  
    
    UPDATE t_pipeline SET b_paused = v_status;
    COMMIT;
    
    WHILE ((v_pipline_processing > 0) AND (v_status = 1)) LOOP
     SELECT COUNT(*)
     INTO v_pipline_processing
     FROM t_pipeline 
     WHERE b_processing = 1;
     
        IF v_timeout > 12 THEN /* wait up to 2 minutes for pipeline state */
            raise_application_error (-20002, 'Unable to pause pipeline. Try to do it manually.');
        END IF;

        DBMS_LOCK.SLEEP(10);
        v_timeout := v_timeout + 1;
    END LOOP;
    
    /* silently let the process continue if we exceed 2 minutes to let core processes run */
END;
