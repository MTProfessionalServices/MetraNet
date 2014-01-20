using System;
using MetraTech.UI.Common;

public partial class _Default : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!String.IsNullOrEmpty(Request["LoadCurrentUser"]))
    {
      if (Request["LoadCurrentUser"].ToLower() == "true")
      {
        ((MasterPages_MetraNetExt)Master).LoadUserAccount = @"/MetraNet/ManageAccount.aspx?id=" + UI.User.AccountId + "&URL=" + Server.UrlEncode(Decrypt(Request["URL"]));
      }
    }
    else
    {
      if (!String.IsNullOrEmpty(Request.QueryString["URL"]))
      {
        //need to strip out ?refreshCache= params...not sure how they've been added, though
        string url = Request.QueryString["URL"];

        int startPos = url.IndexOf("?refreshCache");
        if (startPos >= 0)
        {
          url = url.Substring(0, startPos);
        }
        ((MasterPages_MetraNetExt)Master).StartingURL = Decrypt(url);
      }
    }

  }
}
