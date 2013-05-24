using System;
using System.Workflow.Runtime;

namespace MetraTech.ActivityServices.PersistenceService
{
    public sealed class MTDbPersistenceWorkflowInstanceDescription : IDbPersistenceWorkflowInstanceDescription
    {
        private Guid workflowInstanceId;
        private string suspendOrTerminateDescription;
        private WorkflowStatus status;
        private DateTime nextTimerExpiration;
        private bool isBlocked;

        public MTDbPersistenceWorkflowInstanceDescription(Guid workflowInstanceId,
                                                              string suspendOrTerminateDescription,
                                                              WorkflowStatus status, DateTime nextTimerExpiration,
                                                              bool isBlocked)
        {
            this.workflowInstanceId = workflowInstanceId;
            this.suspendOrTerminateDescription = suspendOrTerminateDescription;
            this.status = status;
            this.nextTimerExpiration = nextTimerExpiration;
            this.isBlocked = isBlocked;
        }

        public bool IsBlocked
        {
            get { return isBlocked; }
        }

        public DateTime NextTimerExpiration
        {
            get { return nextTimerExpiration; }
        }

        public WorkflowStatus Status
        {
            get { return status; }
        }

        public string SuspendOrTerminateDescription
        {
            get { return suspendOrTerminateDescription; }
        }

        public Guid WorkflowInstanceId
        {
            get { return workflowInstanceId; }
        }
    }
}