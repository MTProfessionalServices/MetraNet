using System;
using MetraTech.UI.Common;
using MetraTech.Security;
using MetraTech.Interop.RCD;
using System.Xml;

public partial class TicketToAgreements : MTPage
{
    public string URL = "";
    public string gotoUrl = "Default.aspx";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (UI.CoarseCheckCapability("View Agreement Template"))
        {
            // check manage account hierarchy cap
            string username = UI.User.UserName;
            string name_space = UI.User.NameSpace;

            if (name_space == "")
                name_space = "mt";

            var auth = new Auth();
            auth.Initialize(username, name_space);
            string ticket = auth.CreateTicket();

            if (Request.QueryString["URL"] != null)
            {
                gotoUrl = Request.QueryString["URL"];
            }

            URL = String.Format(
              "{0}?UserName={1}-NameSpace={2}-Ticket={3}-refURL={4}-URL={5}-ref={6}",
              "/Agreements/Template/Logon",
              Server.UrlEncode(username),
              Server.UrlEncode(name_space),
              Server.UrlEncode(ticket),
              Server.UrlEncode(@"/MetraNet/Welcome.aspx"),
              Server.UrlEncode(gotoUrl),
              Server.UrlEncode(auth.EncryptStringData(this.Request.UrlReferrer.Host))
              );
        }

    }
}