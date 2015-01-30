using System;
using System.Linq;
using System.ServiceModel;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.MetraPay;
using MetraTech.Interop.MTYAAC;
using MetraTech.Security;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;

public partial class MetraControl_Payments_ChangeStatus : MTPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    // Check for MetraControl Login
    var auth = new Auth();
    auth.Initialize(UI.User.UserName, UI.User.NameSpace);
    if (!auth.HasAppLoginCapability(UI.SessionContext as IMTSessionContext, "MCM")) return;

    if (!UI.CoarseCheckCapability("Manage Payment Server"))
    {
      Response.End();
      return;
    }

    if (!IsPostBack)
    {
      // If we get passed FailureIDs on the Form or QueryString we use those,
      // otherwise we use what is in the SelectedIDs session.  The session
      // is set when select all is sent to the QueryService.
      if (Request["FailureIDs"] != null)
      {
        Session["SelectedIDs"] = Request["FailureIDs"];
      }

      radManualPending.Checked = true;
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      // Get the ids
      string failureIDs = Session["SelectedIDs"].ToString();
      string newStatus = "";
      string comment = tbComment.Text;

      if (radManualPending.Checked) newStatus = radManualPending.Value;
      if (radManualReversed.Checked) newStatus = radManualReversed.Value;

      using (new HighResolutionTimer("SetPaymentStatus"))
      {

        CleanupTransactionServiceClient client = null;

        try
        {
            client = new CleanupTransactionServiceClient();
            if (client.ClientCredentials != null)
            {
                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            var ids = failureIDs.Split(new[] { ',' }).Select(str => new Guid(str)).ToList();

            var state = TransactionState.MANUAL_PENDING;
            if (newStatus == "P")
            {
                state = TransactionState.MANUAL_PENDING;
            }
            else if (newStatus == "R")
            {
                state = TransactionState.MANUALLY_REVERSED;
            }

            client.SetPaymentStatus(ids, state, comment);
            client.Close();
            client = null;

            // Instead of going to another page we refresh the store, and close the popup.
            jsCheckProgress.Text = @"<script>refreshAndClose();</script>";
        }
        catch (FaultException<MASBasicFaultDetail> mbe)
        {
            SetMASError(mbe);
        }
        catch (Exception ex)
        {
            Logger.LogException("Error changing payment status", ex);
            throw;
        }
        finally
        {
          if (client != null)
          {
            client.Abort();
          }
        }
      }


    }
    catch (Exception exp)
    {
      SetError(exp.Message);
    }
  }

}