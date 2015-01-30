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
        client.ApproveAllAccountCredits(ref miscAdjustments, UI.User.AccountId);
        response.Success = true;
        //response.Message = "Successfully approved all miscellaneous adjustments.";
        var message = GetGlobalResourceObject("Adjustments", "TEXT_Successfully_approved_all_miscellaneous_adjustments");
        if (message != null)
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
}