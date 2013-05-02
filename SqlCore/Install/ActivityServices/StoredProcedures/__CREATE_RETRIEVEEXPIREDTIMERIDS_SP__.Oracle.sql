
              CREATE OR REPLACE PROCEDURE WFRetrieveExpiredTimerIds
              (p_id_owner nvarchar2,
               p_dt_ownedUntil date,
               p_now date,
               p_result out sys_refcursor) 
               AS
               Begin
               /* gkc 9/27/07 allow return of multiple "id_instance" by adding a "sys_refcursor" parameter */
               open p_result for 
               SELECT id_instance FROM t_wf_InstanceState
                  WHERE dt_nextTimer<p_now AND n_status<>1 AND n_status<>3 AND n_status<>2 /* not n_blocked and not completed and not terminated and not suspended */
                      AND ((n_unlocked=1 AND id_owner IS NULL) OR dt_ownedUntil<to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') );
                END WFRetrieveExpiredTimerIds;
              