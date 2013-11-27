update t_failed_transaction set 
        State = '%%STATE%%' where tx_FailureCompoundID_encoded = '%%SESSION_UID%%'