select tx_StageName, tx_Plugin, tx_ErrorMessage
from t_failed_transaction
where tx_Batch_Encoded = '%%STRING_BATCH_ID%%'

		