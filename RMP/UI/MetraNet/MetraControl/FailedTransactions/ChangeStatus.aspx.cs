using System;
using System.Web.UI.WebControls;
using MetraTech.Interop.MTYAAC;
using MetraTech.Security;
using MetraTech.UI.Common;

public partial class MetraControl_FailedTransactions_ChangeStatus : MTPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    // Verify the user has permission to view this page
    if (!UI.CoarseCheckCapability("Update Failed Transactions"))
        Response.End();

    // If we get passed FailureIDs on the Form or QueryString we use those,
    // otherwise we use what is in the SelectedIDs session.  The session
    // is set when select all is sent to the QueryService.
    if (Request["FailureIDs"] != null)
    {
      Session["SelectedIDs"] = Request["FailureIDs"];
    }

    if (Request["Action"] == "resubmit")
    {
      PanelEditStatus.Visible = false;
      HandleBulkResubmit();
      return;
    }

    BindEnums();
  }

  private void HandleBulkResubmit()
  {
    //Asked to do resubmit directly
    try
    {
      //Get the ids
      string failureIDs = Session["SelectedIDs"].ToString();
      var colFailureIDs = FailedTransactions.GetMTCollectionFromValues(failureIDs, ',');

      var rerunID = FailedTransactions.BulkResubmitFailedTransactions(colFailureIDs, UI.SessionContext);
      
      // Start checking progress
      jsCheckProgress.Text = String.Format(@"<script>checkProgress({0});</script>", rerunID);
    }
    catch (Exception exp)
    {
      SetError(exp.Message);
    }
  }

  private void BindEnums()
  {
    ddDismissedReasonCode.Items.Add(new ListItem("--", ""));
    foreach (var dismissed in Enum.GetValues(typeof(MetraTech.DomainModel.Enums.SystemConfig.Metratech_com_failedtransaction.DismissedReasonCode)))
    {
      ddDismissedReasonCode.Items.Add(new ListItem(Enum.GetName(typeof(MetraTech.DomainModel.Enums.SystemConfig.Metratech_com_failedtransaction.DismissedReasonCode), dismissed), dismissed.ToString()));
    }

    ddInvestigationReasonCode.Items.Add(new ListItem("--", ""));
    foreach (var investigation in Enum.GetValues(typeof(MetraTech.DomainModel.Enums.SystemConfig.Metratech_com_failedtransaction.InvestigationReasonCode)))
    {
      ddInvestigationReasonCode.Items.Add(new ListItem(Enum.GetName(typeof(MetraTech.DomainModel.Enums.SystemConfig.Metratech_com_failedtransaction.InvestigationReasonCode), investigation), investigation.ToString()));
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      // Get the ids
      string failureIDs = Session["SelectedIDs"].ToString();
      var colFailureIDs = FailedTransactions.GetMTCollectionFromValues(failureIDs, ','); 

      string newStatus = "N";
      string reasonCode = "";

      if (radOpen.Checked) newStatus = radOpen.Value;
      if (radCorrected.Checked) newStatus = radCorrected.Value;
      if (radDismissed.Checked)
      {
        newStatus = radDismissed.Value;
        reasonCode = ddDismissedReasonCode.SelectedValue;
      }
      if (radUnder.Checked)
      {
        newStatus = radUnder.Value;
        reasonCode = ddInvestigationReasonCode.SelectedValue;
      }
      
      FailedTransactions.BulkUpdateFailedTransactionStatus(colFailureIDs, newStatus, reasonCode, tbComment.Text, UI.SessionContext);

      if (cbResubmitNow.Checked)
      {
        var rerunID = FailedTransactions.BulkResubmitFailedTransactions(colFailureIDs, UI.SessionContext);

        // Start checking progress
        jsCheckProgress.Text = String.Format(@"<script>checkProgress({0});</script>", rerunID);
      }
      else
      {
        // Instead of going to another page we refresh the store, and close the popup.
        jsCheckProgress.Text = @"<script>refreshAndClose();</script>";
      }
    }
    catch (Exception exp)
    {
      SetError(exp.Message);
    }
  }

}