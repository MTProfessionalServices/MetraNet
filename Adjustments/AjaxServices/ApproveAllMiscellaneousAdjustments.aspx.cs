using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.ProductView;
using MetraTech.UI.Common;
using System.Text;

public partial class Adjustments_AjaxServices_ApproveAllMiscellaneousAdjustments : MTListServicePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    var response = new AjaxResponse();
    using (new HighResolutionTimer("ApproveAllMiscellaneousAdjustments", 5000))
    {
      AdjustmentsServiceClient client = null;
      
      try
      {
        client = new AdjustmentsServiceClient();

        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        //esr-4446 using Metratech_com_AccountCreditProductView instead of MiscellaneousAdjustment
        MTList<Metratech_com_AccountCreditProductView> miscAdjustments = new MTList<Metratech_com_AccountCreditProductView>();
        // set the sorting anf filtering, but don't pass the paging back
        SetSorting(miscAdjustments);
        SetFilters(miscAdjustments);

        client.Open();
        List<string> creditNoteRequestFailedAccIds = new List<string>();
        string message;

        client.ApproveAllAccountCreditsAndReturnCNFailures(ref miscAdjustments, UI.User.AccountId, ref creditNoteRequestFailedAccIds);
        response.Success = true;
        if (creditNoteRequestFailedAccIds.Count > 0)
        {
          response.Success = false;
          message = string.Format("{0} <br/> {1}", Convert.ToString(GetGlobalResourceObject("Adjustments", "TEXT_Successfully_approved_all_miscellaneous_adjustments")), CreateErrorMessage(creditNoteRequestFailedAccIds));
        }
        else
        {
          response.Success = true;
          message = string.Format("{0} {1}", Convert.ToString(GetGlobalResourceObject("Adjustments", "TEXT_Successfully_approved_all_miscellaneous_adjustments")), Convert.ToString(GetGlobalResourceObject("Adjustments", "TEXT_All_Credit_Notes_Created")));

        }
        response.Message = message.ToString();
        client.Close();
        client = null;
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        response.Success = false;
        response.Message = ex.Detail.ErrorMessages[0];
        Logger.LogError(ex.Detail.ErrorMessages[0]);
      }
      catch (Exception ex)
      {
        response.Success = false;
        response.Message = ex.Message;
        Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
        Response.Write(response.ToJson());
        Response.End();
      }
    }
  }

  private string CreateErrorMessage(List<string> creditNoteRequestFailedAccIds)
  {
    StringBuilder errorMsg = new StringBuilder();

    for (int i = 0; i < creditNoteRequestFailedAccIds.Count; i++)
    {
      string[] accountAndIssuerId = creditNoteRequestFailedAccIds[i].Split(',');
      errorMsg.Append(string.Format(Convert.ToString(GetGlobalResourceObject("Adjustments", "TEXT_Create_Credit_Note_Error")), accountAndIssuerId[0], accountAndIssuerId[1]));
      errorMsg.Append("<br/>");
    }
    Logger.LogDebug(errorMsg.ToString());
    return errorMsg.ToString();
  }

}