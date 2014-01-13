using System;
using MetraTech.Events;
using MetraTech.UI.Common;

public partial class UserControls_JabberControl : System.Web.UI.UserControl
{
  public string JabberId;
  public string JabberToken;
  public string JabberServer;
  public UIManager UI { get { return ((MTPage)Page).UI; } }

  protected void Page_Load(object sender, EventArgs e)
  {
    // Setup JabberId
    JabberId = EventManager.NormalizeJabberId(UI.User.UserName, UI.User.NameSpace);
    JabberServer = EventManager.GetJabberServerName();
    JabberId = JabberId.Replace("@" + JabberServer, "");
    JabberToken = EventManager.GenerateJabberToken(UI.User.UserName, UI.User.NameSpace);
  }
}
