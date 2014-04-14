using System;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.Tools;
using System.Linq;

public partial class ReportsTree : MTPage
{
  #region Variables

  protected const Int32 LIMIT_NUMBER = 500;
  protected string limitDownSearch;

  #endregion

  #region Properties

  public string RefererUrl
  {
    get { return ViewState["RefererURL"] as string; }
    set { ViewState["RefererURL"] = value; }
  }

  public string ReturnUrl
  {
    get { return ViewState["ReturnURL"] as string; }
    set { ViewState["ReturnURL"] = value; }
  }

  #endregion

  #region Events
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      RefererUrl = Encrypt(Request.Url.ToString());

      ResolveReturnURL();
    }
  }

  private string CheckParameter(string parameter)
  {
    string result;
    try
    {
      // SECENG: Allow empty parameters
      if (!string.IsNullOrEmpty(parameter))
      {
        var input = new ApiInput(parameter);
        SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), input);
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
      throw exp;
    }

    return result;
  }

  protected override void OnLoadComplete(EventArgs e)
  {

//    if (String.IsNullOrEmpty(BMEGrid.Title))
    {
//      BMEGrid.Title = Server.HtmlEncode(entity.GetLocalizedLabel());

    }

//    MTTitle1.Text = BMEGrid.Title;

    base.OnLoadComplete(e);
  }

  #endregion

  #region Private Methods

  private void ResolveReturnURL()
  {
    if (String.IsNullOrEmpty(Request["ReturnURL"]))
    {
      if (Request.UrlReferrer != null)
      {
        if (Request.UrlReferrer.ToString().ToLower().Contains("login.aspx") ||
            Request.UrlReferrer.ToString().ToLower().Contains("default.aspx"))
        {
          ReturnUrl = UI.DictionaryManager["DashboardPage"].ToString();
        }
        else
        {
          ReturnUrl = Request.UrlReferrer.ToString();
        }
      }
      else
      {
        ReturnUrl = UI.DictionaryManager["DashboardPage"].ToString();
      }
    }
    else
    {
      ReturnUrl = Request["ReturnURL"].Replace("'", "").Replace("|", "?").Replace("**", "&");
    }
  }

  #endregion
}