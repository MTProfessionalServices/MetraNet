using System;
using MetraTech.UI.Common;

public partial class _Default : MTPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    Session[SiteConstants.ActiveMenu] = "Home";

    if (!string.IsNullOrEmpty(Request.QueryString["URL"]))
    {
      Response.Redirect(Request.QueryString["URL"]);
    }
  }

}