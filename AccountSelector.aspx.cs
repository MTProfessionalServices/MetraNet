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
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.Tools;
using MetraTech.SecurityFramework;

public partial class AccountSelector : MTPage
{
  public string CallbackFunction;
  public string Target;

  protected override void OnLoadComplete(EventArgs e)
  {
    GridRenderer.AddAccountTypeFilter(MyGrid1);
    if(!String.IsNullOrEmpty(Request.QueryString["f"]))
    {
      //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
      CallbackFunction = ValidateJsFunction(Request.QueryString["f"]);
    }

    if (!String.IsNullOrEmpty(Request.QueryString["t"]))
    {
        //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
        Target = CheckParameter(Request.QueryString["t"]);
    }

    if (!String.IsNullOrEmpty(Request.QueryString["multi"]))
    {
      if(Request.QueryString["multi"].ToLower() == "false")
      {
        MyGrid1.MultiSelect = false;
      }
      else
      {
        MyGrid1.MultiSelect = true;
      }
    }
    else
    {
      MyGrid1.MultiSelect = true;
    }

    if ((CallbackFunction == "addCallback") && (Target == "Frame"))
    {
      if (UI.Subscriber.SelectedAccount != null)
      {
        MTGridDataElement el = MyGrid1.FindElementByID("AncestorAccountID");
        if (el != null)
        {
          el.ElementValue2 = AccountLib.GetFieldID(UI.Subscriber.SelectedAccount._AccountID.Value, UI.User,
                                                   ApplicationTime);
          el.ElementValue = UI.Subscriber.SelectedAccount._AccountID.Value.ToString();
        }
      }
    }

    if ((CallbackFunction == "setSelection") && (Target == "Parent"))
    {
      MTGridDataElement el = MyGrid1.FindElementByID("Internal.Folder");
      if (el != null)
      {
        el.FilterHideable = false;
        el.Filterable = true;
        el.DefaultFilter = true;
        el.IsColumn = true;
        el.ElementValue2 = "True";
        el.ElementValue = "True";
      }
    }
    else
    {
      MTGridDataElement el = MyGrid1.FindElementByID("Internal.Folder");
      if (el != null)
      {
        el.FilterHideable = true;
        el.Filterable = false;
        el.DefaultFilter = false;
        el.IsColumn = false;
      }
    }
  }

    /// <summary>
    /// Check for not allowerd domains
    /// </summary>
    /// <param name="parameter"></param>
    /// <returns></returns>
  private string CheckParameter(string parameter)
  {
      string result = string.Empty;
      try
      {
          // SECENG: Allow empty parameters
          if (!string.IsNullOrEmpty(parameter))
          {
              ApiInput input = new ApiInput(parameter);
              SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), input).ToString();
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
}

