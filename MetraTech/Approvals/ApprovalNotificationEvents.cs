
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.Domain.DataAccess;
using MetraTech.Domain.Events;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;

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
    const string APPROVALSMANAGEMENT_QUERY_FOLDER = "Queries\\ApprovalFramework";

    private static Logger mLogger = new Logger("[ApprovalNotificationEvents]");

    public void ProcessChangeApprovedNotificationEvent(Change change, string comment)
    {
      //Notify the submitter of the change that it has now been approved/made to the system
      //If they were waiting for it before taking further action, they know they can proceed

      try
      {
        var changeDetailsHelper = new ChangeDetailsHelper(change.ChangeDetailsBlob);

        var approvalEvent = new ChangeNotificationEvent
          {
            ApprovalEventType = "Approved",
            ChangeId = change.UniqueItemId,
            Comment = comment,
            ApproverDisplayName = change.ApproverDisplayName,
            //change.ApproverId, //TODO: load some useful account information instead of just the id
            ChangeType = change.ChangeType,
            ItemDisplayName = change.ItemDisplayName
          };

        string submitterEmail = null;
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        using (
          IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(APPROVALSMANAGEMENT_QUERY_FOLDER,
                                                                       "__GET_ACCOUNT_EMAIL__"))
        {
          stmt.AddParam("%%id_acc%%", change.SubmitterId);

          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
            while (rdr.Read())
            {
              submitterEmail = rdr.GetString(0);
            }
          }
        }

        approvalEvent.SubmitterEmail = submitterEmail;

        using (var connection = ConnectionBase.GetDbConnection(new ConnectionInfo("NetMeter"), false))
        using (var context = new MetraNetContext(connection))
        {
          NotificationProcessor.ProcessEvent(context, approvalEvent);
        }
      }
      catch (Exception ex)
      {
        mLogger.LogException("Unable to ProcessChangeApprovedNotificationEvent", ex);
        //Swallow the notification issue as approvals shouldn't return an error
      }

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
      try
      {

      }
      catch (Exception ex)
      {
        mLogger.LogException("Unable to ProcessChangeRequiresApprovalNotificationEvent", ex);
        //Swallow the notification issue as approvals shouldn't return an error
      }
    }

    public void ProcessChangeRequiresApprovalNotificationEvent(Change change)
    {
      //Notify potential approvers that there is a new change waiting for their approval similar to on screen notification
      try
      {

      }
      catch (Exception ex)
      {
        mLogger.LogException("Unable to ProcessChangeRequiresApprovalNotificationEvent", ex);
        //Swallow the notification issue as approvals shouldn't return an error
      }
    }

  }
}
