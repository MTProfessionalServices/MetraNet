using System;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech;
using System.Text;

public partial class AjaxServices_LoadDataFromAccTemplate : MTListServicePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    var sClient = new AccountTemplateServiceClient();
    if (sClient.ClientCredentials != null)
    {
      sClient.ClientCredentials.UserName.UserName = UI.User.UserName;
      sClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
    }
    var tmpl = new AccountTemplate();
    var accType = Request["AccType"];
    int accId;
    // If AccountID specified (Account is updated and can has own template) get their own private template.
    if (Int32.TryParse(Request["AccountID"], out accId)) 
    {
      var acc = new AccountIdentifier(accId);
      try
      {
        sClient.GetTemplateDefForAccountType(acc, accType, MetraTime.Now, true, out tmpl);
      }
      catch (Exception)
      {
        Response.Write("{{}}");
        return;
      }
    }
    // If ParentID specified and it isn't "root" get parent's template.
    var parentTmpl = new AccountTemplate();
    if (Int32.TryParse(Request["ParentID"], out accId))
    {
      if (accId != 1) {
        var parentAcc = new AccountIdentifier(accId);
        sClient.GetPrivateTemplateDefForAccountType(parentAcc, accType, MetraTime.Now, true, out parentTmpl);
      }
    }
    // Replace each parent's template properties with new one in case when it exists in account's template
    foreach (var key in tmpl.Properties.Keys)
    {
      parentTmpl.Properties[key] = tmpl.Properties[key];
    }
    // Make result as JSON string
    var sb = new StringBuilder();
    foreach (var key in parentTmpl.Properties.Keys)
    {
        sb.AppendFormat("{0}'{1}':'{2}'", sb.Length == 0 ? string.Empty : ",", key, parentTmpl.Properties[key]);
    }
    Response.Write(string.Format("{{{0}}}", sb));
  }
}