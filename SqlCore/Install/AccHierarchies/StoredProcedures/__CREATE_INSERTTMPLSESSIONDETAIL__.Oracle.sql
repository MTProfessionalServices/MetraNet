
CREATE OR REPLACE 
PROCEDURE InsertTmplSessionDetail
(
    sessionId NUMBER,
    detailType NUMBER,
    resultInfo NUMBER,
    textData VARCHAR2,
    retryCount NUMBER,
    doCommit CHAR DEFAULT 'Y'
)
AS
BEGIN
    INSERT INTO t_acc_template_session_detail
    (
        id_detail,
        id_session,
        n_detail_type,
        n_result,
        dt_detail,
        nm_text,
        n_retry_count
    )
    VALUES
    (
        seq_template_session_detail.NEXTVAL,
        sessionId,
        detailType,
        resultInfo,
        sysdate,
        textData,
        retryCount
    );

    IF (doCommit = 'Y') THEN
        COMMIT;
    END IF;
END;