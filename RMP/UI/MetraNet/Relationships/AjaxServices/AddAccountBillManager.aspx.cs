using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;

using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class Relationships_AjaxServices_AddAccountBillManager : MTListServicePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      var response = new AjaxResponse();
      using (new HighResolutionTimer("AddAccountBillManager", 5000))
      {
        RelationshipServiceClient client = null;

        try
        {
          client = new RelationshipServiceClient();

          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }

          client.Open();
          string id = Request.Params["ids"];

          AccountBillManager mgr = new AccountBillManager();
          mgr.AdminID = System.Convert.ToInt32(id);
          mgr.AccountID = UI.Subscriber.SelectedAccount._AccountID.Value;


          client.AddAccountBillManager(mgr);
          response.Success = true;
          response.Message = "Successfully added account bill manager.";
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