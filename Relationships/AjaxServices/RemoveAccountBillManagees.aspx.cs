using System;
using System.Collections;
using System.Collections.Generic;
using System.ServiceModel;

using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class Relationships_AjaxServices_RemoveAccountBillManagees : MTListServicePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      var response = new AjaxResponse();
      using (new HighResolutionTimer("RemoveAccountBillManagees", 5000))
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
          string ids = Request.Params["ids"];
          string[] parsedIds = ids.Split(new char[] { ',' });

          List<int> accountIds = new List<int>();
          foreach (string id in parsedIds)
          {
            accountIds.Add(System.Convert.ToInt32(id));
          }

          client.RemoveBillManagees(UI.Subscriber.SelectedAccount._AccountID.Value, accountIds);
          response.Success = true;
          response.Message = "Successfully removed account bill managees.";
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