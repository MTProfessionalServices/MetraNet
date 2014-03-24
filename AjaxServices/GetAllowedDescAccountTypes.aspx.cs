using System;
using System.Collections.Generic;
using System.ServiceModel;
using System.Web.Script.Serialization;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Common;


public partial class AjaxServices_GetAllowedDescAccountTypes : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    List<string> accTypeNames = new List<string>();
    AccountServiceClient client = null;

    try
    {
      long accountId = -1;

      if (!String.IsNullOrEmpty(Request["id"]))
      {
        accountId = int.Parse(Request["id"]);
        Logger.LogDebug("Recieves accountID={0}", accountId);
      }

      client = new AccountServiceClient();
      
      client.ClientCredentials.UserName.UserName = UI.User.Ticket;
      client.ClientCredentials.UserName.Password = String.Empty;

      if (accountId > 0)
      {
        client.GetAllowedDescendantAccountTypeNames(accountId, out accTypeNames);
      }
      else
      {
        Logger.LogDebug("accountID is not set, so all types will be returned for account hierarchy");

        MetraTech.Domain.Account.AccountTypeParameters accParam = new MetraTech.Domain.Account.AccountTypeParameters();
        accParam.IsVisibleInHierarchy = true;
           
        client.GetAllAccountTypeNames(accParam, out accTypeNames);
      }
    }
    finally
    {
      if (client != null)
      {
         if(client.State == CommunicationState.Faulted)
           client.Abort();
         else 
           client.Close(); 
      }
    }

    var jss = new JavaScriptSerializer();
    Response.Write(jss.Serialize(accTypeNames));
    Response.End();
  }
}