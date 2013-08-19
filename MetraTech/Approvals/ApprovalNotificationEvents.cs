
namespace MetraTech.Approvals
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using MetraTech.DomainModel.BaseTypes;


    public class ApprovalNotificationEvents
    {
        private static Logger mLogger = new Logger("[ApprovalLogTestNotificationEvents]");

        public void ProcessChangeApprovedNotificationEvent(Change change, string comment)
        {
            //Notify the submitter of the change that it has now been approved/made to the system
            //If they were waiting for it before taking further action, they know they can proceed

            string sampleMessage = string.Format("The {2} change you submitted was approved by {0} ({1})", change.ApproverDisplayName, change.ApproverId, change.ChangeType.ToString());
            if (!string.IsNullOrEmpty(change.Comment))
            {
              sampleMessage += System.Environment.NewLine + "Comment from approver:" + change.Comment;
            }

            //Send to submitter
            Logger logger = new Logger("[ApprovalNotificationTest]");
            logger.LogInfo(sampleMessage);
        }

        public void ProcessChangeDeniedNotificationEvent(Change change, string comment)
        {
            //Similar to approved message, may want to generate same way and let the Notification framework set the appropriate message
        }

        public void ProcessChangeRequiresApprovalNotificationEvent(Change change)
        {
            //Notify potential approvers that there is a new change waiting for their approval similar to on screen notification

        }

    }
}
