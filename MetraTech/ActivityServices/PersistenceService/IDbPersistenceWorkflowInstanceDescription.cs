using System;
using System.Workflow.Runtime;

namespace MetraTech.ActivityServices.PersistenceService
{
    public interface IDbPersistenceWorkflowInstanceDescription
    {
        bool IsBlocked { get; }
        DateTime NextTimerExpiration { get; }
        WorkflowStatus Status { get; }
        string SuspendOrTerminateDescription { get; }
        Guid WorkflowInstanceId { get; }
    }
}