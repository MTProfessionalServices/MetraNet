using System;
using MetraTech.UI.Common;
using MetraTech.Security;
using MetraTech.Interop.RCD;
using System.Xml;

public partial class ViewOnlineBill : MTPage
{
  public string URL = "";
  public string gotoUrl = "Default.aspx";

  protected void Page_Load(object sender, EventArgs e)
  {
    if (UI.CoarseCheckCapability("View Online Bill"))
    {
      // check manage account hierarchy cap
      string username = UI.Subscriber["UserName"];
      string name_space = UI.Subscriber["Name_Space"];

      if (name_space == "")
        name_space = "mt";

      var auth = new Auth();
      auth.Initialize(username, name_space, UI.User.UserName, "MetraNet");
      string ticket = auth.CreateTicket();

      string site = "/Samplesite";

      // Find the matching provider_name (aka name_space) from gateway.xml
      IMTRcd rcd = new MTRcd();
      string gatewayPath = rcd.ConfigDir + @"\presserver\gateway.xml";
      var doc = new XmlDocument();
      doc.Load(gatewayPath);
      XmlNodeList nodes = doc.SelectNodes("/xmlconfig/mtconfigdata/site");

      if (nodes != null)
      {
        foreach (XmlNode node in nodes)
        {
          if (node.SelectSingleNode("provider_name").InnerText.ToUpper() == name_space.ToUpper())
          {
            site = node.SelectSingleNode("WebURL").InnerText;
            break;
          }
        }
      }

      if(Request.QueryString["URL"] != null)
      {
        gotoUrl = Request.QueryString["URL"];
      }

      // New MetraView. Pass session variables to logout from asp applications when MetraView user logs out. Valid only when MetraView is loaded from MetraCare
      URL = String.Format(
        "{0}/EntryPoint.aspx?MAM=TRUE&UserName={1}&NameSpace={2}&Ticket={3}&refURL={4}&URL={5}&ref={6}&IsMAMActive={7}&IsMOMActive={8}&IsMCMActive={9}",
        site,
        Server.UrlEncode(username),
        Server.UrlEncode(name_space),
        Server.UrlEncode(ticket),
        Server.UrlEncode(@"/MetraNet/Welcome.aspx"),
        Server.UrlEncode(gotoUrl),
        Server.UrlEncode(auth.EncryptStringData(this.Request.UrlReferrer.Host)),
        Session["IsMAMActive"],
        Session["IsMOMActive"],
        Session["IsMCMActive"]
        );
    }

  }
}
