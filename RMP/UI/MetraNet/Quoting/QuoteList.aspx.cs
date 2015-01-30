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

namespace MetraNet.Quoting
{
  public partial class QuotesList : MTPage, ICallbackEventHandler
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
      AccountsFilterValue = Request["Accounts"];
      if (String.IsNullOrEmpty(AccountsFilterValue)) return;

      if (AccountsFilterValue == "ALL")
        QuoteListGrid.DataSourceURL = @"../AjaxServices/LoadQuotesList.aspx?Accounts=ALL";
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
              result = DeleteQuote(entityIds);
              break;
            }
          case "deleteBulk":
            {
              var ids = value["entityIds"].Split(new[] {','});
              entityIds.AddRange(ids.Select(s => int.Parse(s, CultureInfo.InvariantCulture)));
              result = DeleteQuote(entityIds);
              break;
            }
          case "convertOne":
            {
              var entityId = int.Parse(value["entityId"], CultureInfo.InvariantCulture);              
              result = ConvertQuote(entityId);
              break;
            }
        }
        
      }
      catch (Exception ex)
      {
        Logger.LogError(ex.Message);
        result = new {result = "error", errorMessage = ex.Message};
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

    private object DeleteQuote(IEnumerable<int> entityIds)
    {
      object result;
      try
      {
        using (var client = new QuotingServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          client.DeleteQuotes(entityIds);
          result = new {result = "ok"};
        }
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        result = new {result = "error", errorMessage = ex.Detail.ErrorMessages[0]};
      }
      catch (FaultException<MASPartialSuccessFaultDetail> ex)
      {
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        result = new { result = "error", errorMessage = ex.Detail.ErrorMessages[0] };
      }
      return result;
    }

    private object ConvertQuote(int entityId)
    {
      object result;
      try
      {
        using (var client = new QuotingServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          client.ConvertToSubscription(entityId);
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
    #endregion
  }
}
