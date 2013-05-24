using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Net;
using System.Text;
using System.IO;
using MetraTech.ActivityServices.Common;
using System.Reflection;
using MetraTech.PageNav.ClientProxies;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.ComponentModel;

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
      string errorMessage = "";
      Response.StatusCode = 500;

      foreach (string msg in fe.Detail.ErrorMessages)
      {
          errorMessage += string.Format("{0}{1}", msg, (errorMessage.Length > 0 ? "; " : ""));// "\r\n";
      }

      string errCodeString = Utils.ExtractString(errorMessage, "status '", "'");
      if (errCodeString != "")
      {
        string detailedError = Utils.MTErrorMessage(errCodeString);
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
      string errorMessage = "{" + String.Format("'Out_ErrorText':'{0}'", ce.Message.Replace("'", "\'")) + "}";
      Response.Write(errorMessage);
      Logger.LogError(ce.Message);
      Response.End();
      return;
    }
    catch (Exception ex)
    {
      Response.StatusCode = 500;
      Response.StatusDescription = Response.Status;
      string errorMessage = "{" + String.Format("'Out_ErrorText':'{0}'", ex.Message.Replace("'", "\'")) + "}";
      Response.Write(errorMessage);
      Logger.LogError(ex.Message);
      Response.End();
      return;
    }

    CMASEventClientProxyBase proxyData = (CMASEventClientProxyBase)gde.DynamicObject;
    if (proxyData.Out_StateInitData != null)
    {
      if (proxyData.Out_StateInitData.ContainsKey("PageInstanceId"))
      {
        if (proxyData.Out_StateInitData["PageInstanceId"] != null)
        {
          this.PageNav.State = proxyData.Out_StateInitData["PageInstanceId"].ToString();

          Dictionary<string, CMASEventClientProxyBase> data = this.PageNav.mCachedResponseData;
          lock (data)
          {
            // Cache proxyData (representing output values) by Guid
            this.PageNav.mCachedResponseData.Add(this.PageNav.State, proxyData);
          }
        }
      }
    }
    

    string json = String.Empty;
    string outPropertyName = Request["OutPropertyName"];

    if (String.IsNullOrEmpty(outPropertyName))
    {
      json = gde.JSon;
    }
    else
    {
      json = gde.GetPropertyAsJSon(outPropertyName);
    }
    Logger.LogInfo("PageNav JSON = " + json);
    Response.Write(json);
    Response.End();
  }

  protected void ParseParameters()
  {
    gde.State = Request["State"];
    gde.ProcessorInstanceId = Request["ProcessorID"];
    gde.AccountId = UI.User.AccountId.ToString();
    gde.Operation = Request["Operation"];

    string additionalArguments = Request["Args"];
    if (!String.IsNullOrEmpty(additionalArguments)) 
    {
      ParseAdditionalArguments(additionalArguments);
    }
  }

  protected void ProcessKeyValuePairElement(string element)
  {
    int firstEquals = element.IndexOf("=");

    string key = element.Substring(0, firstEquals);
    string value = element.Substring(firstEquals + 1);

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

  protected void ParseAdditionalArguments(string args)
  {
    string[] elementSeparator = new string[] {"**"}; //instead of regular &    
    string[] keyValuePair = new string[] { };

    if (args.Length == 0)
    {
      return;
    }

    //break each element into array of key value pairs
    string[] elements = args.Split(elementSeparator, StringSplitOptions.None);

    //check the case when there is only one element
    if (args.Length > 0 && elements.Length == 0)
    {
      ProcessKeyValuePairElement(args);
    }

    //iterate through each key value pairs
    foreach (string elt in elements)
    {
      ProcessKeyValuePairElement(elt);
    }
  }
    
}
