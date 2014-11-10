using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.Web.UI;
using MetraTech.UI.Common;

namespace MetraNet.AccountConfigSets
{
  public partial class ManageSubscriptionParameters : MTPage, ICallbackEventHandler
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      var cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
      var callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
      Page.ClientScript.RegisterClientScriptBlock(GetType(), "CallServer", callbackScript, true);

      ParseRequest();
    }
    
    private void ParseRequest()
    {
      var mode = Request["mode"];
      object title = "";
      switch (mode)
      {
        case "ADD":
          //title = GetLocalResourceObject("TEXT_MANAGE_ACCOUNTCONFIGSET");
          //if (title != null)
          //ManageSubscriptionParameterTitle.Text = title.ToString();

          break;
        default:
          //title = GetLocalResourceObject("TEXT_MANAGE_ACCOUNTCONFIGSET");
          //if (title != null)
          //ManageSubscriptionParameterTitle.Text = title.ToString();

          break;
      }
    }

    #region Implementation of ICallbackEventHandler

    private string _callbackResult = string.Empty;

    /// <summary>
    /// Processes a callback event that targets a control.
    /// </summary>
    /// <param name="eventArgument">A string that represents an event argument to pass to the event handler.</param>
    public void RaiseCallbackEvent(string eventArgument)
    {
      var serializer = new JavaScriptSerializer();
      var value = serializer.Deserialize<Dictionary<string, string[]>>(eventArgument);
      
      if (value != null)
      {
        _callbackResult = serializer.Serialize(value);
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

    #endregion
  }
}