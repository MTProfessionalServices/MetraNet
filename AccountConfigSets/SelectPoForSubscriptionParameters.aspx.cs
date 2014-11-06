using System;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.SecurityFramework;
using MetraTech.UI.Tools;

namespace MetraNet.AccountConfigSets
{
  public partial class SelectPoForSubscriptionParameters : MTPage
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

// ReSharper disable SpecifyACultureInStringConversionExplicitly
      var arg = new MTGridDataBindingArgument("POEffectiveDate", ApplicationTime.ToString());
// ReSharper restore SpecifyACultureInStringConversionExplicitly
      POListGrid.DataBinder.Arguments.Add(arg);

      const string inputfiltertype = "PO";
      PartitionLibrary.SetupFilterGridForPartition(POListGrid, inputfiltertype);

      base.OnLoadComplete(e);
    }

  }
}