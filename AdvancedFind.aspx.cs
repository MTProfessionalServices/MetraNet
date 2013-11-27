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
using System.Reflection;
using System.Collections.Generic;

using MetraTech.DomainModel.Common;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.DomainModel.AccountTypes;


public partial class AdvancedFind : MTPage
{
  protected override void OnLoad(EventArgs e)
  {
    base.OnLoad(e);
    Session["AdvancedSearchUserName"] = UI.User.UserName;
    Session["AdvancedSearchPass"] = UI.User.SessionPassword;
    Session["AdvancedSearchAccount"] = UI.SessionContext.AccountID;
    Session["AdvancedSearchPageUrl"] = HttpUtility.HtmlEncode(HttpUtility.UrlDecode(Page.Request.Url.PathAndQuery).Replace(";", string.Empty).Replace("'", string.Empty).Replace("\"", string.Empty).Replace("+", string.Empty));
    Session["AdvancedSearchGridClientId"] = MyGrid1.ClientID;

    SearchByInvoice.OnClientClick = "return searchByInvoceNumber();";
    ClearInvoiceNumber.OnClientClick = string.Format("var ctrl=Ext.getCmp(('{0}'));if(ctrl!=null)ctrl.setValue('');return false;", InvoiceNumber.ClientID);
  }

  protected override void OnLoadComplete(EventArgs e)   
  {
    GridRenderer.AddAccountTypeFilter(MyGrid1);
    GridRenderer.AddPriceListFilter(MyGrid1, UI);
    if(!String.IsNullOrEmpty(Request.QueryString["AncestorAccountID"]))
    {
      string ancestorID = Request.QueryString["AncestorAccountID"];

      MTGridDataElement el = MyGrid1.FindElementByID("AncestorAccountID");
      if (el != null)
      {
        el.ElementValue2 = AccountLib.GetFieldID(int.Parse(ancestorID), UI.User, ApplicationTime);
        el.ElementValue = ancestorID;
        MyGrid1.SearchOnLoad = true;
      }
    }

    if (!String.IsNullOrEmpty(Request.QueryString["UserName"]))
    {
      string username = Request.QueryString["UserName"];

      MTGridDataElement el = MyGrid1.FindElementByID("UserName");
      if (el != null)
      {
        el.ElementValue = username;
        MyGrid1.SearchOnLoad = true;
      }
    }

    base.OnLoadComplete(e);
  }

  protected string GetVirtualFolder() {
    string path = AppDomain.CurrentDomain.FriendlyName;
    path = path.Substring(path.LastIndexOf("/"));
    path = path.Substring(0, path.IndexOf("-"));
    return path;
  }
}
