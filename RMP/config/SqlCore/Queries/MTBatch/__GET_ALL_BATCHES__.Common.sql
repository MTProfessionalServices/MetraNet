
        SELECT
        id_batch as BatchTableId,
        tx_batch_encoded as BatchId,
        tx_name as Name,
        tx_namespace as Namespace,
        case tx_status
        when 'A' Then 'Open'
        when 'B' Then 'Backed Out'
        when 'R' Then 'Resubmitted'
        when 'F' Then 'Failed'
        else 'Ask Raju'
        end as Status,
        tx_source as Source,
        tx_sequence as Sequence,
        dt_crt as Creation,
        dt_first as First,
        dt_last as "Recent",
        n_completed as Completed,
        n_failed as Failed,
        n_expected as Expected, 
        n_dismissed Dismissed
        FROM
        t_batch
      