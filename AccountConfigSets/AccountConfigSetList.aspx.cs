using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.ServiceModel;
using System.Web.Script.Serialization;
using System.Web.UI;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;

namespace MetraNet.AccountConfigSets
{
  public partial class AccountConfigSetList : MTPage, ICallbackEventHandler
  {
    protected string AccountsFilterValue;
    protected void Page_Load(object sender, EventArgs e)
    {
      var cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
      var callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
      Page.ClientScript.RegisterClientScriptBlock(GetType(), "CallServer", callbackScript, true);
    }

    protected override void OnLoadComplete(EventArgs e)
    {
      AccountConfigSetListGrid.DataSourceURL = @"../AjaxServices/LoadAccountConfigSetList.aspx";
    }

    #region Implementation of ICallbackEventHandler

    private string _callbackResult = string.Empty;

    /// <summary>
    /// Processes a callback event that targets a control.
    /// </summary>
    /// <param name="eventArgument">A string that represents an event argument to pass to the event handler.</param>
    public void RaiseCallbackEvent(string eventArgument)
    {
      object result = null;
      var serializer = new JavaScriptSerializer();
      var value = serializer.Deserialize<Dictionary<string, string>>(eventArgument);
      var action = value["action"];

      try
      {
        var entityIds = new List<int>();
        switch (action)
        {
          case "deleteOne":
            {
              entityIds.Add(int.Parse(value["entityId"], CultureInfo.InvariantCulture));
              result = DeleteAcs(entityIds);
              break;
            }
          case "deleteBulk":
            {
              var ids = value["entityIds"].Split(new[] { ',' });
              entityIds.AddRange(ids.Select(s => int.Parse(s, CultureInfo.InvariantCulture)));
              result = DeleteAcs(entityIds);
              break;
            }
          case "terminateBulk":
            {
              var ids = value["entityIds"].Split(new[] { ',' });
              entityIds.AddRange(ids.Select(s => int.Parse(s, CultureInfo.InvariantCulture)));
              result = TerminateAcs(entityIds);
              break;
            }
          case "terminateOne":
            {
              entityIds.Add(int.Parse(value["entityId"], CultureInfo.InvariantCulture));
              result = TerminateAcs(entityIds);
              break;
            }
          case "exchangeRanks":
            {
              var entityId1 = int.Parse(value["entityId1"], CultureInfo.InvariantCulture);
              var entityId2 = int.Parse(value["entityId2"], CultureInfo.InvariantCulture);
              result = ExchangeRanks(entityId1, entityId2);
              break;
            }
        }

      }
      catch (Exception ex)
      {
        Logger.LogError(ex.Message);
        result = new { result = "error", errorMessage = ex.Message };
      }

      if (result != null)
      {
        _callbackResult = serializer.Serialize(result);
      }
    }

    /// <summary>
    /// Returns the results of a callback event that targets a control.
    /// </summary>
    /// <returns>
    /// The result of the callback.
    /// </returns>
    public string GetCallbackResult()
    {
      return _callbackResult;
    }

    private object ExchangeRanks(int acsId1, int acsId2)
    {
      object result;
      try
      {
        using (var client = new AccountConfigurationSetServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          client.ExchangeRanks(acsId1, acsId2);
          result = new { result = "ok" };
        }
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        result = new { result = "error", errorMessage = ex.Detail.ErrorMessages[0] };
      }

      return result;
    }

    private object DeleteAcs(IEnumerable<int> entityIds)
    {
      object result;
      try
      {
        using (var client = new AccountConfigurationSetServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          client.DeleteAccountConfigSet(entityIds.ToArray());
          result = new { result = "ok" };
        }
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        result = new { result = "error", errorMessage = ex.Detail.ErrorMessages[0] };
      }
      catch (FaultException<MASPartialSuccessFaultDetail> ex)
      {
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        var errorMessageStr = "";
        foreach (var mes in ex.Detail.ErrorMessages)
          errorMessageStr += "; " + mes;
        result = new { result = "error", errorMessage = errorMessageStr.Substring(2, errorMessageStr.Length - 2) };
      }
      return result;
    }

    private object TerminateAcs(IEnumerable<int> entityIds)
    {
      object result;
      try
      {
        using (var client = new AccountConfigurationSetServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          client.TerminateAccountConfigSets(entityIds.ToList());
          result = new { result = "ok" };
        }
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        result = new { result = "error", errorMessage = ex.Detail.ErrorMessages[0] };
      }
      catch (FaultException<MASPartialSuccessFaultDetail> ex)
      {
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        var errorMessageStr = "";
        foreach (var mes in ex.Detail.ErrorMessages)
          errorMessageStr += "; " + mes;
        result = new { result = "error", errorMessage = errorMessageStr.Substring(2, errorMessageStr.Length - 2) };
      }
      return result;
    }

    #endregion
  }
}
