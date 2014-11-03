
CREATE OR REPLACE 
PROCEDURE inserttemplatesession
(
    id_template_owner INT,
    nm_acc_type VARCHAR2,
    id_submitter INT,
    nm_host VARCHAR2,
    n_status INT,
    n_accts INT,
    n_subs INT,
    session_id OUT INT,
    doCommit CHAR DEFAULT 'Y'
)
AS
BEGIN
     getcurrentid(
            p_nm_current => 'id_template_session',
            p_id_current => session_id
        );
     insert into t_acc_template_session(id_session, id_template_owner, nm_acc_type, dt_submission, id_submitter, nm_host, n_status, n_accts, n_subs)
    values (session_id, id_template_owner, nm_acc_type, CURRENT_DATE, id_submitter, nm_host, n_status, n_accts, n_subs);
    IF (doCommit = 'Y') THEN
        COMMIT;
    END IF;
END;