using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech;
using System.Text;

public partial class AjaxServices_LoadDataFromAccTemplate : MTListServicePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    var sClient = new AccountTemplateServiceClient();
    sClient.ClientCredentials.UserName.UserName = UI.User.UserName;
    sClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
    var aClient = new AccountServiceClient();
    aClient.ClientCredentials.UserName.UserName = UI.User.UserName;
    aClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
    AccountTemplate tmpl = new AccountTemplate();
    string accType = Request["AccType"];
    int accId;
    // If AccountID specified (Account is updated and can has own template) get their own private template.
    if (Int32.TryParse(Request["AccountID"], out accId)) 
    {
      AccountIdentifier acc = new AccountIdentifier(accId);
      sClient.GetTemplateDefForAccountType(acc, accType, MetraTech.MetraTime.Now, true, out tmpl);
    }
    // If ParentID specified and it isn't "root" get parent's template.
    AccountTemplate parentTmpl = new AccountTemplate();
    if (Int32.TryParse(Request["ParentID"], out accId))
    {
      if (accId != 1) {
        AccountIdentifier parentAcc = new AccountIdentifier(accId);
        sClient.GetPrivateTemplateDefForAccountType(parentAcc, accType, MetraTech.MetraTime.Now, true, out parentTmpl);
      }
    }
    // Replace each parent's template properties with new one in case when it exists in account's template
    foreach (var key in tmpl.Properties.Keys)
    {
      parentTmpl.Properties[key] = tmpl.Properties[key];
    }
    // Make result as JSON string
    StringBuilder sb = new StringBuilder();
    foreach (var key in parentTmpl.Properties.Keys)
    {
        sb.AppendFormat("{0}'{1}':'{2}'", sb.Length == 0 ? string.Empty : ",", key, parentTmpl.Properties[key].ToString());
    }
    Response.Write(string.Format("{{{0}}}", sb));
  }
}