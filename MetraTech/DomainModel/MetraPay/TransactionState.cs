using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.MetraPay
{
    [Serializable]
    public enum TransactionState
    {
        RECEIVED_REQUEST = 0,
        SUBMITTED_REQUEST,
        RECEIVED_RESPONSE,
    	SUCCESS,
        FAILURE,
        REVERSED,
        REJECTED,
        MANUAL_PENDING,
        MANUALLY_REVERSED,
        POST_PROCESSING_SUCCESSFUL,
        DUPLICATE
    }
}
