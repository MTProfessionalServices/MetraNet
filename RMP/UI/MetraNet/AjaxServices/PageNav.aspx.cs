using System;
using System.Globalization;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;
using System.ServiceModel;
using MetraTech.UI.Tools;

public partial class PageNav : MTPage
{
  protected GenericDataExtractor gde;

  protected void Page_Load(object sender, EventArgs e)
  {
    gde = new GenericDataExtractor(UI.User);

    ParseParameters();

    try
    {
      gde.GetData();
    }
    catch (FaultException<MASBasicFaultDetail> fe)
    {
      var errorMessage = string.Empty;
      Response.StatusCode = 500;

      foreach (var msg in fe.Detail.ErrorMessages)
      {
          errorMessage += string.Format("{0}{1}", msg, (errorMessage.Length > 0 ? "; " : ""));// "\r\n";
      }

      var errCodeString = Utils.ExtractString(errorMessage, "status '", "'");
      if (errCodeString != "")
      {
        var detailedError = Utils.MTErrorMessage(errCodeString);
        errorMessage += "  " + detailedError;
      }

      Response.StatusDescription = Response.Status;
      errorMessage = "{" + String.Format("'Out_ErrorText':'{0}'", errorMessage.Replace("'", "\'")) + "}";
      Response.Write(errorMessage);
      Logger.LogError(errorMessage);
      Response.End();
      return;
    }
    catch (CommunicationException ce)
    {
      Response.StatusCode = 500;
      Response.StatusDescription = Response.Status;
      var errorMessage = "{" + String.Format("'Out_ErrorText':'{0}'", ce.Message.Replace("'", "\'")) + "}";
      Response.Write(errorMessage);
      Logger.LogError(ce.Message);
      Response.End();
      return;
    }
    catch (Exception ex)
    {
      Response.StatusCode = 500;
      Response.StatusDescription = Response.Status;
      var errorMessage = "{" + String.Format("'Out_ErrorText':'{0}'", ex.Message.Replace("'", "\'")) + "}";
      Response.Write(errorMessage);
      Logger.LogError(ex.Message);
      Response.End();
      return;
    }

    var proxyData = (CMASEventClientProxyBase)gde.DynamicObject;
    if (proxyData.Out_StateInitData != null)
    {
      if (proxyData.Out_StateInitData.ContainsKey("PageInstanceId"))
      {
        if (proxyData.Out_StateInitData["PageInstanceId"] != null)
        {
          PageNav.State = proxyData.Out_StateInitData["PageInstanceId"].ToString();

          var data = PageNav.mCachedResponseData;
          lock (data)
          {
            // Cache proxyData (representing output values) by Guid
            if (!PageNav.mCachedResponseData.ContainsKey(PageNav.State))
              PageNav.mCachedResponseData.Add(PageNav.State, proxyData);
          }
        }
      }
    }
    
    var outPropertyName = Request["OutPropertyName"];
    var json = String.IsNullOrEmpty(outPropertyName) ? gde.JSon : gde.GetPropertyAsJSon(outPropertyName);

    Logger.LogInfo("PageNav JSON = " + json);
    Response.Write(json);
    Response.End();
  }

  protected void ParseParameters()
  {
    gde.State = Request["State"];
    gde.ProcessorInstanceId = Request["ProcessorID"];
    gde.AccountId = UI.User.AccountId.ToString(CultureInfo.CurrentCulture);
    gde.Operation = Request["Operation"];

    var additionalArguments = Request["Args"];
    if (!String.IsNullOrEmpty(additionalArguments)) 
    {
      ParseAdditionalArguments(additionalArguments);
    }
  }

  protected void ParseAdditionalArguments(string args)
  {
    if (args.Length == 0)
    {
      return;
    }

    var elementSeparator = new[] { "**" }; //instead of regular &  

    //break each element into array of key value pairs
    var elements = args.Split(elementSeparator, StringSplitOptions.None);

    //check the case when there is only one element
    if (args.Length > 0 && elements.Length == 0)
    {
      ProcessKeyValuePairElement(args);
    }

    //iterate through each key value pairs
    foreach (var elt in elements)
    {
      ProcessKeyValuePairElement(elt);
    }
  }

  protected void ProcessKeyValuePairElement(string element)
  {
    var firstEquals = element.IndexOf("=", StringComparison.Ordinal);
    var key = element.Substring(0, firstEquals);
    var value = element.Substring(firstEquals + 1);

    //populate the arguments dictionary
    if (!gde.Arguments.ContainsKey(key))
    {
      gde.Arguments.Add(key, value);
    }
    else
    {
      gde.Arguments[key] = value;
    }
  }
}