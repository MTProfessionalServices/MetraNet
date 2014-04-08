using System;
using MetraTech.UI.Common;
using MetraTech.Security;

public partial class ViewOnlineBill : MTPage
{
  public string URL = "";
  public string gotoUrl = "Default.aspx";

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("View Online Bill")) return;
    // check manage account hierarchy cap
    var userName = UI.Subscriber["UserName"];
    var nameSpace = UI.Subscriber["Name_Space"];

    if (nameSpace == "")
      nameSpace = "mt";

    var auth = new Auth();
    auth.Initialize(userName, nameSpace, UI.User.UserName, "MetraNet");
    var ticket = auth.CreateTicket();

    var site = MetraTech.Core.UI.CoreUISiteGateway.GetRootURL(nameSpace);

    if (Request.QueryString["URL"] != null)
    {
      gotoUrl = Request.QueryString["URL"];
    }

    // New MetraView. Pass session variables to logout from asp applications when MetraView user logs out. Valid only when MetraView is loaded from MetraCare
    URL = String.Format(
      "{0}/EntryPoint.aspx?MAM=TRUE&UserName={1}&NameSpace={2}&Ticket={3}&refURL={4}&URL={5}&ref={6}&IsMAMActive={7}&IsMOMActive={8}&IsMCMActive={9}",
      site,
      Server.UrlEncode(userName),
      Server.UrlEncode(nameSpace),
      Server.UrlEncode(ticket),
      Server.UrlEncode(@"/MetraNet/Welcome.aspx"),
      Server.UrlEncode(gotoUrl),
      Server.UrlEncode(auth.EncryptStringData(Request.UrlReferrer.Host)),
      Session["IsMAMActive"],
      Session["IsMOMActive"],
      Session["IsMCMActive"]
      );
  }
}