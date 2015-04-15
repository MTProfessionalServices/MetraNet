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

using MetraTech.DomainModel.Common;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.SecurityFramework;

public partial class MessagePage : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (Request.QueryString["msg"] != null)
    {
      lblMessage.Text = Request.QueryString["msg"].ToString().EncodeForHtml().Replace("&lt;br/&gt;","<br/>");
    }

    if (Request.QueryString["title"] != null)
    {
      // CORE-5933 Don't HTML-encode here because MTTitle rendering takes care of that.
      lblTitle.Text = Request.QueryString["title"].ToString();
    }
    else
    {
      lblTitle.Text = Resources.Resource.TEXT_CONFIRMATION;
    }

    if (Request.QueryString["iswarning"] != null)
    {
      if (Request.QueryString["iswarning"].ToString().ToLower() == "true")
        MessageDiv.Attributes["class"] = "WarningMessage";
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    string redirectUrl = Request.QueryString["returnUrl"];

    if (string.IsNullOrWhiteSpace(redirectUrl))
    {
      Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
    }
    else
    {
      Response.Redirect(redirectUrl);
    }
  }
}
