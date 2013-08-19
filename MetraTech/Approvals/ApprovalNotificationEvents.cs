
namespace MetraTech.Approvals
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using MetraTech.DomainModel.BaseTypes;
  using MetraTech.Application;


    public class ApprovalNotificationEvents
    {
        private static Logger mLogger = new Logger("[ApprovalLogTestNotificationEvents]");

        public void ProcessChangeApprovedNotificationEvent(Change change, string comment)
        {
            //Notify the submitter of the change that it has now been approved/made to the system
            //If they were waiting for it before taking further action, they know they can proceed

          /*
          var changeDetailsHelper = new ChangeDetailsHelper(change.ChangeDetailsBlob);

          var approvalEvent = new ChangeNotificationEvent { ChangeId = changeId, Comment = comment };

          DomainModel.BaseTypes.Account account = new DomainModel.BaseTypes.Account(); // TODO: retrieve account for this.SessionContext.AccountID
          // HELP... HOW TO DO THIS???
          //
          //AccountService s;
          //AccountService_LoadAccountWithViews_Client acc = new AccountService_LoadAccountWithViews_Client();
          //acc.In_acct = new AccountIdentifier(accountId);
          //acc.In_timeStamp = appTime;

          ////acc.UserName = userData.UserName;
          ////acc.Password = userData.SessionPassword;

          //acc.UserName = userData.Ticket;
          //acc.Password = String.Empty;

          //acc.Invoke();

          //if (acc.Out_account != null)
          //{
          //    account = acc.Out_account;
          //}

          ContactView contactView = null;
          var views = account.GetViews();
          foreach (var view in views.SelectMany(x => x.Value))
          {
            contactView = view as ContactView;
            if (contactView == null) continue;
            if (contactView.ContactType == ContactType.Bill_To) break;
          }

          if (contactView != null) approvalEvent.SubmitterEmail = contactView.Email;

          using (var connection = ConnectionBase.GetDbConnection(new ConnectionInfo("NetMeter"), false))
          using (var context = new MetraNetContext(connection))
          {
            NotificationProcessor.ProcessEvent(context, approvalEvent);
          }
          */
          /*
            //Testing
            string sampleMessage = string.Format("The {2} change you submitted for {3} (Id: {4}) was approved by {0} ({1})", change.ApproverDisplayName, change.ApproverId, change.ChangeType.ToString(), change.ItemDisplayName, change.UniqueItemId);
            if (!string.IsNullOrEmpty(change.Comment))
            {
              sampleMessage += System.Environment.NewLine + "Comment from approver:" + change.Comment;
            }

            //Send to submitter
            Logger logger = new Logger("[ApprovalNotificationTest]");
            logger.LogInfo(sampleMessage);

            //Sample email might be:
            /* Set submitter email address
            Rudi will make sure we get: ApproverId, ApproverDisplayName, LocalizedChangeTypeDisplayName ?
             */
            
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
