using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Globalization;

using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using System.Text;

public partial class Adjustments_AjaxServices_ApproveMiscellaneousAdjustment : MTListServicePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    var response = new AjaxResponse();
    using (new HighResolutionTimer("ApproveMiscellaneousAdjustments", 5000))
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

        client.Open();
        string ids = Request.Params["ids"];
        string[] parsedIds = ids.Split(new char[] { ',' });


        List<long> sessionIds = new List<long>();
        foreach (string s in parsedIds)
        {
          long item = System.Convert.ToInt64(s);
          sessionIds.Add(item);
        }
        List<string> creditNoteRequestFailedAccIds = new List<string>();
        string message;
        //client.ApproveMiscellaneousAdjustments(sessionIds, UI.User.AccountId);
        client.ApproveAccountCreditsAndReturnCNFailures(sessionIds, UI.User.AccountId, ref creditNoteRequestFailedAccIds);

        if (creditNoteRequestFailedAccIds.Count > 0)
        {
          response.Success = false;
          message = string.Format("{0} <br/> {1}", Convert.ToString(GetGlobalResourceObject("Adjustments", "TEXT_Successfully_approved_miscellaneous_adjustment")), CreateErrorMessage(creditNoteRequestFailedAccIds)); 
        }
        else
        {
          response.Success = true;
          message = string.Format("{0} {1}", Convert.ToString(GetGlobalResourceObject("Adjustments", "TEXT_Successfully_approved_miscellaneous_adjustment")), Convert.ToString(GetGlobalResourceObject("Adjustments", "TEXT_Credit_Notes_Created")));

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