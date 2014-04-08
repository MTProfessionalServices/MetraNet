using System;
using MetraTech.UI.Common;

public partial class _Default : MTPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    Session[SiteConstants.ActiveMenu] = "Home";

        var crypto = false;
        if (!string.IsNullOrEmpty(Request.QueryString["Crypto"]))
            bool.TryParse(Request.QueryString["Crypto"], out crypto);
        
    if (!string.IsNullOrEmpty(Request.QueryString["URL"]))
            Response.Redirect(crypto ? Decrypt(Request.QueryString["URL"]) : Request.QueryString["URL"]);
    }

}