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
using MetraTech.UI.Controls;
using MetraTech.SecurityFramework;
using MetraTech.UI.Tools;


namespace MetraNet.AccountConfigSets
{
  public partial class AccountConfigSetSubscriptionParamsList : MTPage, ICallbackEventHandler
  {
    public string CallbackFunction;
    public string Target;
    /// <summary>
    /// 
    /// </summary>
    /// <param name="val">String to validate</param>
    /// <returns>Empty string in case of fail</returns>
    private string ValidateJsFunction(string val)
    {
      string result = val;
      try
      {
        Utils.ValidateJsFunction(val);
      }
      catch (ValidatorInputDataException validatorInputDataException)
      {
        Session[Constants.ERROR] = validatorInputDataException.Message;
        result = string.Empty;
      }
      catch (Exception exp)
      {
        Session[Constants.ERROR] = exp.Message;
        throw;
      }
      return result;
    }
    /// <summary>
    /// Check for not allowerd domains
    /// </summary>
    /// <param name="parameter"></param>
    /// <returns></returns>
    private string CheckParameter(string parameter)
    {
      string result;
      try
      {
        // SECENG: Allow empty parameters
        if (!string.IsNullOrEmpty(parameter))
        {
          var input = new ApiInput(parameter);
          return SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), input).ToString();
        }

        result = parameter;
      }
      catch (AccessControllerException accessExp)
      {
        Session[Constants.ERROR] = accessExp.Message;
        result = string.Empty;
      }
      catch (Exception exp)
      {
        Session[Constants.ERROR] = exp.Message;
        throw;
      }
      return result;
    }

    protected override void OnLoadComplete(EventArgs e)
    {
      if (!String.IsNullOrEmpty(Request.QueryString["f"]))
      {
        //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
        CallbackFunction = ValidateJsFunction(Request.QueryString["f"]);
      }

      if (!String.IsNullOrEmpty(Request.QueryString["t"]))
      {
        //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
        Target = CheckParameter(Request.QueryString["t"]);
      }
      
      base.OnLoadComplete(e);
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
      //var cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
      //var callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
      //Page.ClientScript.RegisterClientScriptBlock(GetType(), "CallServer", callbackScript, true);
    }
    
    #region Implementation of ICallbackEventHandler

    private string _callbackResult = string.Empty;

    /// <summary>
    /// Processes a callback event that targets a control.
    /// </summary>
    /// <param name="eventArgument">A string that represents an event argument to pass to the event handler.</param>
    public void RaiseCallbackEvent(string eventArgument)
    {
      //object result = null;
      //var serializer = new JavaScriptSerializer();
      //var value = serializer.Deserialize<Dictionary<string, string>>(eventArgument);
      //var action = value["action"];

      //try
      //{
      //  //var entityIds = new List<int>();
      //  //switch (action)
      //  //{
      //  //  case "deleteOne":
      //  //    {
      //  //      entityIds.Add(int.Parse(value["entityId"], CultureInfo.InvariantCulture));
      //  //      result = DeleteAcs(entityIds);
      //  //      break;
      //  //    }
      //  //  case "deleteBulk":
      //  //    {
      //  //      var ids = value["entityIds"].Split(new[] { ',' });
      //  //      entityIds.AddRange(ids.Select(s => int.Parse(s, CultureInfo.InvariantCulture)));
      //  //      result = DeleteAcs(entityIds);
      //  //      break;
      //  //    }
      //  //  case "terminateBulk":
      //  //    {
      //  //      var ids = value["entityIds"].Split(new[] { ',' });
      //  //      entityIds.AddRange(ids.Select(s => int.Parse(s, CultureInfo.InvariantCulture)));
      //  //      result = TerminateAcs(entityIds);
      //  //      break;
      //  //    }
      //  //  case "terminateOne":
      //  //    {
      //  //      entityIds.Add(int.Parse(value["entityId"], CultureInfo.InvariantCulture));
      //  //      result = TerminateAcs(entityIds);
      //  //      break;
      //  //    }
      //  //}

      //}
      //catch (Exception ex)
      //{
      //  Logger.LogError(ex.Message);
      //  result = new { result = "error", errorMessage = ex.Message };
      //}

      //if (result != null)
      //{
      //  _callbackResult = serializer.Serialize(result);
      //}
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
